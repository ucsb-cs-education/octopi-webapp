require 'student_signin_module'
class StudentPortal::BaseController < ApplicationController
  include StudentSigninModule
  after_action :update_autosignout_time

  def exception_redirect_path(login_dependent=false)
    if signed_in_student? || !login_dependent
      main_app.student_portal_root_path
    else
      main_app.student_portal_signin_path
    end
  end


  def current_user
    current_student
  end

  def user_for_paper_trail
    if signed_in_student?
      current_student.id
    else
      super
    end
  end

  def path_for_returning_student
    if cookies.signed[:student_last_module]
      student_portal_module_path(cookies.signed[:student_last_module])
    else
      if (mod = current_school_class.module_pages.student_visible.first).nil?
        nil
      else
        student_portal_module_path(mod)
      end
    end
  end

  def redirect_back_or(default)
    redirect_to (
                    if session[:return_to]
                      session[:return_to]
                    elsif cookies.signed[:student_last_module]
                      student_portal_module_path(cookies.signed[:student_last_module])
                    else
                      default
                    end
                )
    session.delete(:return_to)
  end

end
