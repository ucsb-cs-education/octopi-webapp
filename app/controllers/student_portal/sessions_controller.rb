class StudentPortal::SessionsController < StudentPortal::BaseController
  def new
    render(:layout => 'layouts/devise')
  end

  def create
    school_id = params[:session][:school] || -1
    login_name = params[:session][:login_name] || ""
    password = params[:session][:password] || ""

    student = Student.find_by(school_id: school_id, login_name: login_name.downcase)

    if student && student.authenticate(password)
      sign_in_student student
      redirect_back_or student_portal_root_url
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', layout: 'layouts/devise'
    end
  end

  def destroy
    sign_out_student
    redirect_to student_portal_root_url
  end
end
