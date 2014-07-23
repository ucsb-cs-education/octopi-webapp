class StudentPortal::BaseController < ApplicationController
  include StudentPortal::BaseHelper
  after_action :update_autosignout_time
  alias_method :current_user, :current_student


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

end
