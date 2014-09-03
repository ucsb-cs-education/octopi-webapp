class SchoolClassesController < ApplicationController
  include SchoolClassesHelper
  load_and_authorize_resource :school_class, except: [:teacher_index]
  load_and_authorize_resource :school, only: [:index, :new, :create]
  before_action :load_school, only: [:edit]
  before_action :find_columns, only: [:edit_students_via_csv]

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

  def edit_student
    @student = Student.find(params[:student][:id])
    respond_to do |format|
      format.js do
        js false
      end
    end
  end

  def edit_class
  end

  def remove_class_role
    Staff.find(params[:staff_id]).remove_role :teacher, SchoolClass.find(@school_class.id)
    redirect_to edit_class_school_class_path
  end


  def add_teacher
    @teacher = Staff.find(params[:staff][:id])
    authorize! :update, @teacher
    @teacher.grant :teacher, SchoolClass.find(@school_class.id)
    respond_to do |format|
      format.js do
        js false
      end
    end
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

  def student_spreadsheet_help
    #dont need to do anything
  end

  def find_columns
    errors = []
    begin
      #open the file
      if params[:student_csv][:csv].nil?
        raise "You must choose a spreadsheet to do this."
      end
      tmpfl = params[:student_csv][:csv]
      extension = File.extname(tmpfl.original_filename)
      if supported_filetype.include?(extension)
        @sheet = Roo::Spreadsheet.open(tmpfl.tempfile.to_path, extension: extension.to_sym).to_a
      else
        raise "Cannot read a '#{extension}' file. Try saving as a .xls, .xlsx, .ods, or .csv file."
      end

      #parse the file into something usable
      @sheet[0].each_with_index { |header, num|
        unless (header =~ /first(\s*name)?\s*\z/i).nil?
          errors.push("Columns '#{@sheet[0][@first_name_column]}' and '#{header}' are both valid headers for First name.
          Please remove or rename one and try again.") unless @first_name_column.nil?
          @first_name_column = num
        end
        unless (header =~ /last(\s*name)?\s*\z/i).nil?
          errors.push("Columns '#{@sheet[0][@last_name_column]}' and '#{header}' are both valid headers for Last name.
          Please remove or rename one and try again.") unless @last_name_column.nil?
          @last_name_column = num
        end
        unless (header =~ /password\s*\z/i).nil?
          errors.push("Columns '#{@sheet[0][@password_column]}' and '#{header}' are both valid headers for Password.
          Please remove or rename one and try again.") unless @password_column.nil?
          @password_column = num
        end
        unless (header =~ /password(\s*|[-_])confirm/i).nil?
          errors.push("Columns '#{@sheet[0][@password_confirmation_column]}' and '#{header}'
          are both valid headers for Password confirmation. Please remove or rename one and try again.") unless @password_confirmation_column.nil?
          @password_confirmation_column = num
        end
        unless (header =~ /login(\s*name)?\s*\z/i).nil?
          errors.push("Columns '#{@sheet[0][@login_name_column]}' and '#{header}' are both valid headers for Login name.
          Please remove or rename one and try again.") unless @login_name_column.nil?
          @login_name_column = num
        end
        unless (header =~ /octopi(\s*student)?\s*(id|num)/i).nil?
          errors.push("Columns '#{@sheet[0][@id_column]}' and '#{header}' are both valid headers for Octopi student number.
          Please remove or rename one and try again.") unless @id_column.nil?
          @id_column = num
        end
      }

      if @first_name_column == nil
        errors.push("Could not find a first name column. Please create a column with the header 'First' or 'First name' and try again.")
      end
      if @last_name_column == nil
        errors.push("Could not find a last name column. Please create a column with the header 'Last' or 'Last name' and try again.")
      end
      if @login_name_column == nil
        errors.push("Could not find a login name column. Please create a column with the header 'Login' or 'Login name' and try again.")
      end
      if @password_column == nil
        errors.push("Could not find a password column. Please create a column with the header 'Password' and try again.")
      end
      if @password_confirmation_column == nil
        errors.push("Could not find a password confirmation column. Please create a column with the header 'Password confirmation' or 'Password confirm' and try again.")
      end
      if @id_column == nil
        msg = "Could not find an 'Octopi student number' or 'Octopi id' column. This is valid, but some duplicate students may be created. Please carefully
        check that no unintended changes are made."
        if errors.empty?
          flash[:warning] = msg
        else
          errors.push(msg)
        end
      end

    rescue Exception => e
      errors.push(e.message)
    end

    unless errors.empty?
      flash[:error] = errors.join("<br/>").html_safe
      redirect_to :back
    end
  end

  # POST /school_classes/:id/edit_students_via_csv
  def edit_students_via_csv
    #put this whole thing into a model?
    #its going to be in a worker anyway

    @login_name_list = []
    school = @school_class.school
    @actions = @sheet.each_with_index.map { |student, i|
      unless i == 0
        action = nil;
        flags = [];
        student[@login_name_column] = student[@login_name_column].downcase unless student[@login_name_column]==nil
        if @id_column == nil || student[@id_column] == nil
          if this_student = school.students.find_by(login_name: student[@login_name_column])
            unless school.students.include?(this_student) && (this_student.first_name.strip==student[@first_name_column].strip && this_student.last_name.strip==student[@last_name_column].strip)
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
            elsif @login_name_list.include?(student[@login_name_column])
              action = :repeat_new_login
              flags.push(:error)
            elsif school.students.find_by(first_name: student[@first_name_column], last_name: student[@last_name_column])!=nil
              action = :create
              flags.push(:duplicate)
              @login_name_list.push(student[@login_name_column])
            else
              action = :create
              @login_name_list.push(student[@login_name_column])
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
              if this_student = school.students.find_by(login_name: student[@login_name_column])
                flags.push(this_student.name)
                flags.push(this_student.id)
              end
            end
          rescue ActiveRecord::RecordNotFound => e
            action = :student_does_not_exist
            flags.push(:error)
            flags.push(student[@id_column].to_i)
            if this_student = school.students.find_by(login_name: student[@login_name_column])
              flags.push(this_student.name)
              flags.push(this_student.id)
            end
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

  # POST /school_classes/:id/do_csv_actions
  def do_csv_actions
    begin
      #All of the '.strip's are here to prevent whitespace from causing problems.
      SchoolClass.transaction do
        unless params[:student_csv].nil?
          params[:student_csv].each { |action|
            action = JSON.parse action[1]
            case action['action']
              when 'create'
                Student.transaction do
                  @student = Student.new(first_name: action['first_name'].strip, last_name: action['last_name'].strip,
                                         login_name: action['login_name'].strip, password: action['password'].strip,
                                         password_confirmation: action['password'].strip, school: @school_class.school)
                  @student.save!
                  @school_class.students << @student unless @school_class.students.include? @student
                end
              when 'change_password'
                @student = Student.find(action['flags'][0])
                @student.update_attributes({password: action['password'].strip, password_confirmation: action['password'].strip})
                @student.save!
              when 'add_to_class'
                @student = Student.find(action['flags'][0])
                @student.school_classes << @school_class unless @student.school_classes.include?(@school_class)
            end
          }
          flash[:success] = 'Success!'
        end
        redirect_to edit_school_class_path(@school_class)
      end
    rescue Exception => e
      flash[:error] = "An error has occured. Please contact us so we can resolve the issue. Possible causes include attempts to do some
      actions twice and using the incorrect Octopi student number. Please check your sheet for problems and try again."
      redirect_to edit_school_class_path(@school_class)
    end
  end

  def download_class_csv
    class_book = Axlsx::Package.new
    wb = class_book.workbook
    wb.add_worksheet(:name => "Class Info") do |sheet|
      sheet.add_row ["First Name", "Last Name", "Login Name", "Octopi Student Number", "Password", "Password Confirmation"]
      ordered_students.each { |student|
        sheet.add_row [student.first_name, student.last_name, student.login_name, student.id]
      }
    end
    js false;
    output = StringIO.new
    class_book.use_shared_strings = true
    output.write(class_book.to_stream.read)
    send_data output.string, filename: "#{@school_class.name}_info.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
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
          redirect_to :back, notice: 'Class was successfully updated.'
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

  def supported_filetype
    ['.xls', '.xlsx', '.ods', '.csv']
  end

end
