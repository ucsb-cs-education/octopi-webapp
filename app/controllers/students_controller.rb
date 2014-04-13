
class StudentsController < ApplicationController
  #check_authorization
  #load_resource
  load_and_authorize_resource :school
  load_and_authorize_resource
  skip_authorize_resource :only => :new
  before_filter :load_school

  def index
    #@students = Student.all
    @students = @school.students

  end

  def new
    render(:layout => 'layouts/devise')
    @student = Student.new
  end

  def create
    @student = Student.new(student_params)
    #Might need to add School.with_role(:school_admin, current_user).pluck(:id).includes(@student.school_id) && , lets chcek
    if @student.save
      flash[:success] = "Student saved successfully."
      redirect_to students_path
    else
      render 'new'
    end
  end

  private
    def student_params
      params.require(:student).permit(:name, :password, :password_confirmation, :school_id)
    end

    def load_school
      @school = School.find(params[:school_id])
    end

end
