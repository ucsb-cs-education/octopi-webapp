class SchoolClassesController < ApplicationController
  include SchoolClassesHelper
  load_and_authorize_resource :school_class, except: [:teacher_index]
  load_and_authorize_resource :school, only: [:index, :new, :create]
  before_action :load_school, only: [:edit]
  respond_to :xls, :html, :js


  # Deep actions
  # GET /schools/:school_id/school_classes
  def index
    @school_classes = @school.school_classes
  end

  def teacher_index
    authenticate_staff!
    if current_staff.super_staff?
      @schools = School.all
    else
      @schools = School.with_role(:teacher, current_staff)
    end
    if @schools.empty?
      flash[:error] = 'You are not a teacher at any schools! You must be a teacher to access this page. Other users must access through the school directly.'
      redirect_to staff_root_path
    else
      schools = {}
      @schools.each do |school|
        schools[school.name] = {id: school.id, name: school.name, classes: []}
        #'ERROR:  bind message supplies 2 parameters, but prepared statement "a4" requires 1'
        classes = school.school_classes
        unless current_staff.super_staff?
          #Postgres number of variables error
          # classes = classes.with_role(:teacher, current_staff)
          classes = classes.select { |x| current_staff.has_role? :teacher, x }
        end
        classes.each do |klass|
          schools[klass.school.name][:classes] << klass
        end
      end
      @schools = []
      schools.each do |k, v|
        v[:classes].sort { |x, y| x.name <=> y.name }
        @schools << v
      end
    end

  end

  # POST /schools/:school_id/school_classes
  def new
    @school_class = SchoolClass.new
    render(:layout => 'layouts/devise')
  end

  # GET /schools/:school_id/school_classes/new
  def create
    @school_class = SchoolClass.new(school_class_params)
    @school_class.school = @school
    if @school_class.save
      flash[:success] = 'Class saved successfully.'
      redirect_to @school_class
    end
  end

  def view_as_student
    @school_class = SchoolClass.find(params[:school_class_id])
    pass = SecureRandom.uuid
    test_student = current_staff.test_student
    test_student ||= TestStudent.create(first_name: "TestStudent", last_name: current_staff.last_name,
                                        login_name: SecureRandom.uuid, password: pass,
                                        password_confirmation: pass, school: @school_class.school,
                                        staff: current_staff)
    unless test_student.school_classes.pluck(:id).include? @school_class.id
      test_student.school = @school_class.school
      test_student.school_classes << @school_class
    end
    sign_in_student test_student, @school_class
    redirect_to student_portal_module_path(@school_class.module_pages.first)
  end

  def signout_test_student
    if teacher_using_test_student?
      sign_out_student current_student
    else
      flash[:error] = "You are not signed in as a test student."
    end
    redirect_to :back
  end

  def reset_test_student
    if teacher_using_test_student?
      @school_class = SchoolClass.find(params[:school_class_id])
      current_student.delete_all_data_for(@school_class)
      current_student.school_classes << @school_class
      flash[:success] = "All progress for Test Student reset."
    else
      flash[:error] = "You are not signed in as a test student."
    end
    redirect_to :back
  end

  #Shallow actions
  # GET /school_classes/1
  def show
    @module_pages = @school_class.module_pages.teacher_visible.includes(:activity_pages)

    #these two are entirely for the average completion bar
    @tasks = Task.teacher_visible.where(activity_page: (ActivityPage.where(module_page: @module_pages)))
    task_ids = @tasks.pluck(:id)
    @students = ordered_students
    @responses = TaskResponse.completed.where(student: @students, school_class: @school_class, task_id: task_ids)
    @unlocks = Unlock.where(school_class: @school_class,
                            student: @students,
                            unlockable_id: task_ids,
                            unlockable_type: 'Task')
  end

  # GET /school_classes/1/edit
  def edit
    @student = Student.new
  end


  def add_new_student
    @student = Student.new(student_params)
    @student.school = @school_class.school
    begin
      Student.transaction do
        @student.save!
        @school_class.students << @student unless @school_class.students.include? @student
      end
    rescue ActiveRecord::RecordInvalid
      response.status = :bad_request
    end
    respond_to do |format|
      format.js do
        js false
      end
    end
  end

  # POST /school_classes/:school_class_id/add_student
  def add_student
    @student = Student.find(params[:student][:id])
    authorize! :update, @student
    @school_class.students << @student unless @school_class.students.include? @student
    respond_to do |format|
      format.js do
        js false
      end
    end
  end

  def edit_students_via_csv
    #put this whole thing into a model?
    #its going to be in a worker anyway


    #open the file
    tmpfl = params[:student_csv][:csv]
    extension = tmpfl.original_filename.split('.').last
    sheet = Roo::Spreadsheet.open(tmpfl.tempfile.to_path, extension: extension.to_sym).to_a

    #parse the file into something usable
    sheet[0].each_with_index { |header, num|
      #first name
      unless (header =~ /first/i).nil?
        @first_name_column = num
      end
      #last name
      unless (header =~ /last/i).nil?
        @last_name_column = num
      end
      #password but not password confirmation
      unless (header =~ /password\s*\z/i).nil?
        @password_column = num
      end
      #password confirmation but not password
      unless (header =~ /password(\s*|[-_])confirm/i).nil?
        @password_confirmation_column = num
      end
      #login name
      unless (header =~ /login/i).nil?
        @login_name_column = num
      end
      #octopi id
      #THIS IS TOO LENIENT, NEED TO ENFORCE OCTOPI SOMEWHERE
      unless (header =~ /octopi(\s*|[-_])id/i).nil?
        @id_column = num
      end
    }

    #ERROR HERE IF:
    #ANY ARE NILL
    #ANY REPEAT (error earlier?)

    school = @school_class.school
    @actions = sheet.each_with_index.map { |student, i|
      unless i == 0
        action = nil;
        flags = [];
        student[@login_name_column] = student[@login_name_column].downcase unless student[@login_name_column]==nil
        if student[@id_column] == nil
          if this_student = Student.find_by(login_name: student[@login_name_column])
            unless school.students.include?(this_student) && (this_student.first_name==student[@first_name_column] && this_student.last_name==student[@last_name_column])
              action = :repeat_login_name
              flags.push(:error)
            else
              action = student_found(this_student, student[@password_column])
              flags.push(this_student.id)
              unless student[@password_column] == student[@password_confirmation_column]
                flags.push :incorrect_confirmation
              end
            end
          else
            if student[@login_name_column].nil?
              action = :nil_login
              flags.push(:error)
            elsif student[@first_name_column].nil?
              action = :nil_first_name
              flags.push(:error)
            elsif student[@last_name_column].nil?
              action = :nil_last_name
              flags.push(:error)
            elsif student[@password_column].nil?
              action = :nil_password
              flags.push(:error)
            elsif school.students.include?(Student.find_by(first_name: student[@first_name_column], last_name: student[@last_name_column]))
              action = :create
              flags.push(:duplicate)
            else
              action = :create
            end
            if student[@password_column] != student[@password_confirmation_column] && action!=:nil_password
              flags.push :incorrect_confirmation
            end
          end
        else
          begin
            this_student = Student.find(student[@id_column].to_i)
            if school.students.include?(this_student)
              action = student_found(this_student, student[@password_column])
              flags.push(this_student.id)
              unless student[@password_column] == student[@password_confirmation_column]
                flags.push :incorrect_confirmation
              end
              unless student[@login_name_column] == this_student.login_name
                flags.push :id_login_name_mismatch
              end
            else
              action = :student_not_in_school
              flags.push(:error)
              flags.push(student[@id_column].to_i)
            end
          rescue ActiveRecord::RecordNotFound => e
            action = :student_does_not_exist
            flags.push(:error)
            flags.push(student[@id_column].to_i)
          end
        end

        {action: action, first_name: student[@first_name_column],
         last_name: student[@last_name_column], login_name: student[@login_name_column],
         password: student[@password_column], password_confirmation: student[@password_confirmation_column],
         flags: flags}
      end
    }
  end

  def student_found(student, pass = nil)
    if student.school_classes.include?(@school_class)
      if params[:student_csv][:change_passwords] == "1" && pass!=nil
        :change_password
      end
    else
      :add_to_class
    end
  end

  def do_csv_actions
    begin
      SchoolClass.transaction do
        params[:student_csv].each { |action|
          action = JSON.parse action[1]
          case action['action']
            when 'create'
              Student.transaction do
                @student = Student.new(first_name: action['first_name'], last_name: action['last_name'],
                                       login_name: action['login_name'], password: action['password'],
                                       password_confirmation: action['password'], school: @school_class.school)
                @student.save!
                @school_class.students << @student unless @school_class.students.include? @student
              end
            when 'change_password'
              @student = Student.find(action['flags'][0])
              @student.update_attributes({password: action['password'], password_confirmation: action['password']})
              @student.save!
            when 'add_to_class'
              Student.find(action['flags'][0]).school_classes << @school_class
          end
        }
        flash[:success] = 'Success!'
        redirect_to edit_school_class_path(@school_class)
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to edit_school_class_path(@school_class)
    end
  end

  # POST /school_classes/:school_class_id/manual_unlock
  def manual_unlock
    @school_class.students.each { |x|
      @unlock = Unlock.where(student: x,
                             school_class: @school_class,
                             unlockable_id: params[:students][:unlockable_id],
                             unlockable_type: params[:students][:unlockable_type]).first_or_create
    }
    redirect_to(:back)
  end

  def update
    @school_class = SchoolClass.find(params[:id])
    if @school_class.update(school_class_params)
      respond_to do |format|
        format.html do
          redirect_to edit_school_class_path, notice: 'Class was successfully updated.'
        end
      end
    else
      render action: 'edit'
    end
  end

  private
  def student_params
    params.require(:student).permit(:first_name, :last_name, :login_name, :password, :password_confirmation)
  end

  def school_class_params
    params.require(:school_class).permit(:name, module_page_ids: [])
  end

  def load_school
    @school = @school_class.school
  end

end
