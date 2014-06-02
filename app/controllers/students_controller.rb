class StudentsController < ApplicationController
  load_and_authorize_resource :school, only: [:index, :new, :create, :list_student_logins]
  load_and_authorize_resource
  skip_authorize_resource :school, only: [:list_student_logins]
  before_action :load_students, only: [:index, :list_student_logins]


  # Deep actions
  # GET /schools/:school_id/students
  def index
  end

  # GET /schools/:school_id/student_logins.json
  def list_student_logins
    render json: @students.select(:login_name, :school_id, :id)
  end

  # GET /schools/:school_id/students/new
  def new
    render(:layout => 'layouts/devise')
  end

  # POST /schools/:school_id/students
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

  # Shallow actions
  # GET /students/:id
  def show
  end

  private
    def student_params
      params.require(:student).permit(:name, :login_name, :password, :password_confirmation)
    end

    def load_students
      @students = @school.students
    end

end
