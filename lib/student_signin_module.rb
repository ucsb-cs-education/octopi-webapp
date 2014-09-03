module StudentSigninModule

  def sign_in_student(student, school_class)
    remember_token = Student.new_remember_token
    session[:student_remember_token] = remember_token
    session[:school_class_id] = school_class.id
    student.update_attribute(:remember_token, Student.create_remember_hash(remember_token))
    @current_student = student
    @current_school_class = school_class
    @current_student.current_class = @current_school_class
    @current_student
  end

  def update_autosignout_time
    session[:student_autosignout_time] = 30.days.from_now # We need a way to properly keep logins during snap sessions, so for now we don't log out
  end

  def current_school_class=(school_class)
    @current_school_class = school_class
  end

  def current_student=(student)
    @current_student = student
  end

  def current_student
    if @current_student.nil?
      remember_token = Student.create_remember_hash(session[:student_remember_token])
      @current_student = Student.find_by(remember_token: remember_token)
      if @current_student
        expires_at = session[:student_autosignout_time]
        if expires_at && expires_at < Time.now
          sign_out_student(@current_student)
        end
        update_autosignout_time
        if session[:school_class_id]
          @current_student.current_class ||= SchoolClass.find_by(id: session[:school_class_id])
        end
      end
    end
    @current_student ||= false
  end

  def current_school_class
    if signed_in_student?
      @current_school_class ||= SchoolClass.find_by(id: session[:school_class_id]) if session[:school_class_id]
    end
    @current_school_class
  end

  def current_school_class?(school_class)
    school_class == current_school_class
  end

  def current_student?(student)
    student == current_student
  end

  def signed_in_student?
    # current_student == true or is an object
    !(current_student == false)
  end

  def signed_in_student
    unless signed_in_student?
      store_location
      flash.keep #Keep old flashes - since student_portal doesn't have a globally accessible home, if we redirect home,
      # as a logged out user, then we will redirect again, so we want to keep old warnings.
      flash[:warning] = 'Please sign in.'
      redirect_to student_portal_signin_path
    end
  end

  def sign_out_student(student=nil)
    student ||= current_student
    if student != false
      student.update_attribute(:remember_token,
                               Student.create_remember_hash(Student.new_remember_token))
      session.delete(:remember_token)
      self.current_student = nil
      self.current_school_class = nil
    end
  end

  def store_location
    session[:return_to] = request.url if request.get?
  end

  def teacher_using_test_student?
    current_staff && current_staff.test_student && current_staff.test_student == current_student
  end

end
