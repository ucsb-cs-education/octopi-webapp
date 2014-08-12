class SchoolClassesController < ApplicationController
  load_and_authorize_resource :school_class, except: [:teacher_index]
  load_and_authorize_resource :school, only: [:index, :new, :create]
  before_action :load_school, only: [:edit]


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
        classes = school.school_classes
        unless current_staff.super_staff?
          classes = classes.with_role(:teacher, current_staff)
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

  #Shallow actions
  # GET /school_classes/1
  def show
    @module_pages = @school_class.module_pages.teacher_visible.includes(:activity_pages)

    #these two are entirely for the average completion bar
    @tasks = Task.teacher_visible.where(activity_page: (ActivityPage.where(module_page: @module_pages)))
    task_ids = @tasks.pluck(:id)
    @responses = TaskResponse.completed.where(student: @school_class.students, school_class: @school_class, task_id: task_ids)
    @unlocks = Unlock.where(school_class: @school_class,
                            student: @school_class.students,
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
