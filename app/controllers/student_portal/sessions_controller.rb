class StudentPortal::SessionsController < StudentPortal::BaseController
  load_and_authorize_resource :school
  skip_authorize_resource :school

  def new
    render(:layout => 'layouts/devise')
  end

  def create
    school_id = params[:session][:school] || -1
    login_name = params[:session][:login_name] || ""
    password = params[:session][:password] || ""
    school_class_id = params[:session][:school_class] || -1

    student = Student.find_by(school_id: school_id, login_name: login_name.downcase)
    school_class = SchoolClass.find_by(id: school_class_id)

    if student && school_class && student.authenticate(password)
      sign_in_student student, school_class
      redirect_back_or student_portal_root_url
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', layout: 'layouts/devise'
    end
  end

  def list_school_classes
    school_classes = School.find(params[:school_id]).school_classes
    render json: school_classes.select(:name, :school_id, :id)
  end

  def list_student_logins
    students  = SchoolClass.find(params[:school_class_id]).students
    render json: students.select(:login_name, :school_class_id, :id)
  end


  def destroy
    sign_out_student
    redirect_to student_portal_root_url
  end

end
