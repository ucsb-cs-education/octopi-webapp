module StudentPortal::BaseHelper
  def sign_in(student)
    remember_token = Student.new_remember_token
    session[:remember_token] = remember_token
    student.update_attribute(:remember_token, Student.hash(remember_token))
    self.current_student = student
  end

  def current_student=(student)
    @current_student = student
  end

  def current_student
    remember_token = Student.hash(session[:remember_token])
    @current_student ||= Student.find_by(remember_token: remember_token)
  end

  def current_student?(student)
    student == current_student
  end

  def signed_in_student?
    !current_student.nil?
  end

  def signed_in_student
    unless signed_in_student?
      store_location
      redirect_to student_portal_signin_path, notice: 'Please sign in.'
    end
  end

  def sign_out_student
    current_student.update_attribute(:remember_token,
                                  Student.hash(Student.new_remember_token))
    cookies.delete(:remember_token)
    self.current_student = nil
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url if request.get?
  end

end
