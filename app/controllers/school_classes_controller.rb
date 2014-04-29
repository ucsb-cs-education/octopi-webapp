class SchoolClassesController < ApplicationController
  load_and_authorize_resource
  load_and_authorize_resource :school
  before_action :check_school, only: [:edit, :show, :update, :destroy]

  # GET /schools
  def index
    @school_classes = @school.school_classes
  end

  # GET /schools/1
  def show
    #@school_class = SchoolClass.find(params[:id])
  end

  # GET /school_classes/1/edit
  def edit
    #@school_class = SchoolClass.find(params[:id])
  end

  def add_student

  end

  def new
    @school_class = SchoolClass.new
    render(:layout => 'layouts/devise')
  end

  def update
    @school_class = SchoolClass.find(params[:id])
    if @school_class.update(school_class_params)
      redirect_to [@school, @school_class], notice: 'School was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def create
    @school_class = SchoolClass.new(school_class_params)
    @school_class.school = @school
    #Might need to add School.with_role(:school_admin, current_user).pluck(:id).includes(@student.school_id) && , lets chcek
    if @school_class.save
      flash[:success] = 'Class saved successfully.'
      redirect_to [@school,@school_class]
    else
      render 'new', :layout => 'layouts/devise'
    end
  end

  private
  def school_class_params
    params.require(:school_class).permit(:name)
  end

  def check_school
    if not @school_class.school.eql? @school
      raise CanCan::AccessDenied.new('Class does not belong to specified school',)
    end
  end

end
