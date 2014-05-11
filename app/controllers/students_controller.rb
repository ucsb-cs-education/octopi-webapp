class StudentsController < ApplicationController
  load_and_authorize_resource :school
  load_and_authorize_resource
  skip_authorize_resource :school, :only => [:list_student_logins]
  before_action :check_school, only: [:edit, :show, :update, :destroy]
  before_action :load_students, only: [:index, :list_student_logins]

  def index
  end

  def list_student_logins
    render json: @students.select(:login_name, :school_id, :id)
  end

  def new
    render(:layout => 'layouts/devise')
  end

  def show

  end

  # DELETE /schools/1
  def destroy
    @student.destroy
    redirect_to school_students_path(@school.id)
  end

  def create
    @student = Student.new(student_params)
    @student.school = @school
    #Might need to add School.with_role(:school_admin, current_user).pluck(:id).includes(@student.school_id) && , lets chcek
    if @student.save
      flash[:success] = 'Student saved successfully.'
      redirect_to school_students_path
    else
      render 'new', :layout => 'layouts/devise'
    end
  end

  private
    def student_params
      params.require(:student).permit(:name, :login_name, :password, :password_confirmation)
    end

    def check_school
      if not @student.school.eql? @school
        raise CanCan::AccessDenied.new('Student does not belong to specified school', )
      end
    end

    def load_students
      @students = @school.students
    end

end
