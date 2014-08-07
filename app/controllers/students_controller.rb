class StudentsController < ApplicationController
  load_and_authorize_resource :school, only: [:index, :new, :create]
  load_and_authorize_resource
  skip_authorize_resource :school, only: [:list_student_logins]
  before_action :load_students, only: [:index]
  respond_to :json
  js false


  # Deep actions
  # GET /schools/:school_id/students
  def index
  end

  # GET /schools/:school_id/student_logins.json

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

  def change_class
    original_class = SchoolClass.find(params[:old_class].to_i)
    new_class = SchoolClass.find(params[:new_class].to_i)
    if @student.change_school_class(original_class, new_class, params[:preserve_current]=='true')
      respond_with [{name: original_class.name, value: original_class.id}, {name: new_class.name, value: new_class.id}]
    end
  end

  def remove_class
    school_class = SchoolClass.find(params[:class_id])
    if params['delete_data']=='true'
      respond_with [{name: school_class.name, value: school_class.id}] if @student.delete_all_data_for(school_class)
    else
      respond_with [{name: school_class.name, value: school_class.id}] if @student.soft_remove_from(school_class)
    end
  end

  private
  def student_params
    params.require(:student).permit(:first_name, :last_name, :login_name, :password, :password_confirmation)
  end

  def load_students
    @students = @school.students
  end

end
