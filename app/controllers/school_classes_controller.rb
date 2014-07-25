class SchoolClassesController < ApplicationController
  load_and_authorize_resource :school_class
  load_and_authorize_resource :school, only: [:index, :new, :create]
  before_action :load_school, only: [:edit]


  # Deep actions
  # GET /schools/:school_id/school_classes
  def index
    @school_classes = @school.school_classes
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
    @module_pages = @school_class.module_pages.includes(:activity_pages)
    @unlocks = Unlock.where(school_class:@school_class, student: @school_class.students)
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
