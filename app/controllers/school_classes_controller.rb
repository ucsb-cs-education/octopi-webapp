class SchoolClassesController < ApplicationController
  before_filter :set_school
  #before_action :set_school_class

  # GET /schools
  # GET /schools.json
  def index
    @school_classes = @school.school_classes
  end

  # GET /schools/1
  # GET /schools/1.json
  def show
    @school_class = SchoolClass.find(params[:id])
  end

  # GET /school_classes/1/edit
  def edit
    @school_class = SchoolClass.find(params[:id])
  end

  def new
    render(:layout => 'layouts/devise')
    @school_class = SchoolClass.new
  end

  def update
    @school_class = SchoolClass.find(params[:id])
    respond_to do |format|
      if @school_class.update(school_class_params)
        format.html { redirect_to [@school,@school_class], notice: 'School was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def create
    @school_class = SchoolClass.new(school_class_params)
    @school_class.school = @school
    #Might need to add School.with_role(:school_admin, current_user).pluck(:id).includes(@student.school_id) && , lets chcek
    if @school_class.save
      flash[:success] = 'Class saved successfully.'
      redirect_to school_school_class_path
    else
      render 'new', :layout => 'layouts/devise'
      $stderr.puts @school_class.errors.messages
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_school
    @school = School.find(params[:school_id])
    #if(params[:id]!=nil)
     # @school_class = SchoolClass.find(params[:id])
    #end
  end
  def school_class_params
     params.require(:school_class).permit(:name)
  end

end
