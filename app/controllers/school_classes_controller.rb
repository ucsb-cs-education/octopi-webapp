class SchoolClassesController < ApplicationController
  load_and_authorize_resource
  load_and_authorize_resource :school, only: [:index, :new, :create]


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
  end

  # GET /school_classes/1/edit
  def edit
  end


  def add_new_student
    @student = Student.new(student_params)
    @student.school = @school_class.school
    Student.transaction do
      @school_class.students << @student unless @school_class.students.include? @student
    end
    if @student.save
      respond_to do |format|
        format.js    do
          js false
        end
        format.html do
          redirect_to edit_school_class_path, notice: 'Student was successfully added.'
        end

      end
    else
      render 'new', :layout => 'layouts/devise'
    end
  end

  # POST /school_classes/:school_class_id/add_student
  def add_student
    @student = Student.find(params[:student][:id])
    authorize! :update, @student
    @school_class.students << @student unless @school_class.students.include? @student
    respond_to do |format|
      format.js    do
        js false
      end
      format.html do
        redirect_to edit_school_class_path, notice: 'Student was successfully added.'
      end

    end
  end

  def update
    @school_class = SchoolClass.find(params[:id])
    if @school_class.update(school_class_params)
      respond_to do |format|
        format.html do
          redirect_to edit_school_class_path, notice: 'Class was successfully updated.'
        end
        format.js do
          js false
        end
      end

    else
      render action: 'edit'
    end
  end
  private
  def student_params
    params.require(:student).permit(:first_name, :last_name,:login_name, :password, :password_confirmation)
  end

  def school_class_params
    params.require(:school_class).permit(:name)
  end

end
