module StudentPortal::BaseHelper
  def sign_in_student(student)
    remember_token = Student.new_remember_token
    session[:student_remember_token] = remember_token
    update_autosignout_time
    student.update_attribute(:remember_token, Student.create_remember_hash(remember_token))
  end

  def update_autosignout_time
    session[:student_autosignout_time] = 30.minutes.from_now
  end

  def current_student=(student)
    @current_student = student
  end

  def current_student
    remember_token = Student.create_remember_hash(session[:remember_token])
    @current_student ||= Student.find_by(remember_token: remember_token)
    expires_at = session[:student_autosignout_time]
    update_autosignout_time
    if expires_at && expires_at > Time.now
      remember_token = Student.create_remember_hash(session[:student_remember_token])
      @current_student ||= Student.find_by(remember_token: remember_token)
    else
      return nil
    end
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
      flash.keep #Keep old flashes - since student_portal doesn't have a globally accessible home, if we redirect home,
      # as a logged out user, then we will redirect again, so we want to keep old warnings.
      flash[:notice] = 'Please sign in.'
      redirect_to student_portal_signin_path
    end
  end

  def sign_out_student
    current_student.update_attribute(:remember_token,
                                  Student.create_remember_hash(Student.new_remember_token))
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
