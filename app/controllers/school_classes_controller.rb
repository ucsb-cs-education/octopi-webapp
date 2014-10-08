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
    test_student ||= TestStudent.create(first_name: 'TestStudent', last_name: current_staff.last_name,
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
      flash[:error] = 'You are not signed in as a test student.'
    end
    redirect_to :back
  end

  def reset_test_student
    if teacher_using_test_student?
      @school_class = SchoolClass.find(params[:school_class_id])
      current_student.delete_all_data_for(@school_class)
      current_student.school_classes << @school_class
      flash[:success] = 'All progress for Test Student reset.'
    else
      flash[:error] = 'You are not signed in as a test student.'
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

  def student_spreadsheet_help
    #dont need to do anything
  end

  # POST /school_classes/:id/edit_students_via_csv
  def edit_students_via_csv
    #put this whole thing into a model?
    #its going to be in a worker anyway

    @login_name_list = []
    school = @school_class.school
    @actions = @sheet.to_a
    @actions.shift
    @actions.map! { |student|
      action = nil
      flags = []
      first_name = (get_col(student, :first_name) || '').strip
      last_name = (get_col(student, :last_name) || '').strip
      login_name = (get_col(student, :login_name) || '').strip.downcase
      student_id = get_col(student, :student_id).to_i
      password = get_col(student, :password)
      password_confirmation = get_col(student, :password_confirmation)
      if student_id.nil?
        this_student = school.students.find_by(login_name: login_name)
        if this_student.nil?
          action = make_new_student_from_csv(login_name, first_name, last_name, password, password_confirmation, flags)
        else
          if (this_student.first_name == first_name) && (this_student.last_name == last_name)
            action = student_found(this_student, password)
            flags.push(this_student.id)
            unless password == password_confirmation
              flags.push :incorrect_confirmation
            end
          else
            action = :repeat_login_name
            flags.push(:error)
          end
        end
      else
        this_student = Student.find_by(id: student_id)
        if this_student.nil?
          action = :student_does_not_exist
          flags.push(:error)
          flags.push(student_id)
          this_student = school.students.find_by(login_name: login_name)
          if this_student
            flags.push(this_student.name)
            flags.push(this_student.id)
          end
        else
          if school.students.include?(this_student)
            action = student_found(this_student, password)
            flags.push(this_student.id)
            unless password == password_confirmation
              flags.push :incorrect_confirmation
            end
            unless login_name == this_student.login_name
              flags.push :id_login_name_mismatch
            end
          else
            action = :student_not_in_school
            flags.push(:error)
            flags.push(student_id)
            this_student = school.students.find_by(login_name: login_name)
            if this_student
              flags.push(this_student.name)
              flags.push(this_student.id)
            end
          end
        end
      end

      {action: action, first_name: first_name,
       last_name: last_name, login_name: login_name,
       password: password, password_confirmation: password_confirmation,
       flags: flags}
    }
  end

  # POST /school_classes/:id/do_csv_actions
  def do_csv_actions
    begin
      school = @school_class.school
      #All of the '.strip's are here to prevent whitespace from causing problems.
      SchoolClass.transaction do
        unless params[:student_csv].nil?
          params[:student_csv].each { |action|
            action = JSON.parse action[1]
            case action['action']
              when 'create'
                first_name = action['first_name'].strip
                last_name = action['last_name'].strip
                login_name = action['login_name'].strip
                password = action['password'].strip
                password_confirmation = action['password'].strip
                Student.transaction do
                  @student = Student.new(
                      first_name: first_name,
                      last_name: last_name,
                      login_name: login_name,
                      password: password,
                      password_confirmation: password_confirmation,
                      school: school
                  )
                  @student.save!
                  @school_class.students << @student unless @school_class.students.include? @student
                end
              when 'change_password'
                password = action['password'].strip
                password_confirmation = action['password'].strip
                @student = Student.find(action['flags'][0])
                unless @student.school == school
                  raise 'Student must belong to this school'
                end
                @student.update_attributes({
                                               password: password,
                                               password_confirmation: password_confirmation
                                           })
                @student.save!
              when 'add_to_class'
                @student = Student.find(action['flags'][0])
                unless @student.school == school
                  raise 'Student must belong to this school'
                end
                @student.school_classes << @school_class unless @student.school_classes.include?(@school_class)
              else
                # type code here
            end
          }
          flash[:success] = 'Success!'
        end
        redirect_to edit_school_class_path(@school_class)
      end
    rescue Exception => e
      flash[:error] = 'An error has occured. Please contact us so we can resolve the issue. Possible causes include attempts to do some
      actions twice and using the incorrect Octopi student number. Please check your sheet for problems and try again.'
      redirect_to edit_school_class_path(@school_class)
    end
  end

  def download_class_csv
    class_book = Axlsx::Package.new
    wb = class_book.workbook
    wb.add_worksheet(:name => 'Class Info') do |sheet|
      sheet.add_row ['First Name', 'Last Name', 'Login Name', 'Octopi Student Number', 'Password', 'Password Confirmation']
      ordered_students.each { |student|
        sheet.add_row [student.first_name, student.last_name, student.login_name, student.id]
      }
    end
    js false
    output = StringIO.new
    class_book.use_shared_strings = true
    output.write(class_book.to_stream.read)
    send_data output.string, filename: "#{@school_class.name} class info.xlsx", type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
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
  # noinspection RubyStringKeysInHashInspection
  def get_col(student_row, col_symbol)
    student_row[@headers[col_symbol]]
  end

  def student_found(student, pass = nil)
    if student.school_classes.include?(@school_class)
      if params[:student_csv][:change_passwords] == '1' && pass != nil
        :change_password
      end
    else
      :add_to_class
    end
  end

  def make_new_student_from_csv(login_name, first_name, last_name, password, password_confirmation, flags)
    if login_name.empty?
      action = :nil_login
      flags.push(:error)
    elsif first_name.empty?
      action = :nil_first_name
      flags.push(:error)
    elsif last_name.empty?
      action = :nil_last_name
      flags.push(:error)
    elsif password.nil?
      action = :nil_password
      flags.push(:error)
    elsif @login_name_list.include?(login_name)
      action = :repeat_new_login
      flags.push(:error)
    elsif school.students.find_by(first_name: first_name, last_name: last_name)!=nil
      action = :create
      flags.push(:duplicate)
      @login_name_list.push(login_name)
    else
      action = :create
      @login_name_list.push(login_name)
    end
    if (password != password_confirmation) && (action != :nil_password)
      flags.push :incorrect_confirmation
    end
  end

  def find_columns
    errors = []
    @_header_translate ||= {
        'First Name' => :first_name,
        'Last Name' => :last_name,
        'Login Name' => :login_name,
        'Octopi Student Number' => :student_id,
        'Password' => :password,
        'Password Confirmation' => :password_confirmation
    }
    @headers = {}
    begin
      #open the file
      if params[:student_csv][:csv].nil?
        raise 'You must choose a spreadsheet to do this.'
      end

      tmpfl = params[:student_csv][:csv]
      extension = File.extname(tmpfl.original_filename)

      if supported_filetype.include?(extension)
        @sheet = Roo::Spreadsheet.open(tmpfl.tempfile.to_path, extension: extension.to_sym)
      else
        raise "Cannot read a '#{extension}' file. Try saving as a .xls, .xlsx, .ods, or .csv file."
      end

      headers = @sheet.row(1)
      help_text = ' Please see the help page for more information on the required columns.'
      if headers.length != 6
        errors.push('Invalid number of columns.'+help_text)
      end

      # Get the header row, for each key in the header row, lets try to see if we can translate it to a symbol
      # And then put it into the headers dictionary (and throw an error if it already exists)
      @sheet.row(1).each_with_index do |header, i|
        if @_header_translate.has_key?(header)
          translated = @_header_translate[header]
          if @headers.has_key? translated
            errors.push("Duplicate column found (Columns #{@headers[translated]} and #{i}. Please correct this issue and try again.")
            break
          else
            @headers[@_header_translate[header]] = i
          end
        else
          errors.push("Invalid column header:'#{header}'."+help_text)
          break
        end
      end
    rescue Exception => e
      errors.push(e.message)
    end

    unless errors.empty?
      flash[:error] = errors.join('<br/>').html_safe
      redirect_to :back
    end
  end

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
    %w(.xls .xlsx .ods .csv)
  end

end
