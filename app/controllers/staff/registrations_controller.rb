class Staff::RegistrationsController < Devise::RegistrationsController
  protected
  def after_sign_up_path_for(resource)
    new_staff_session_path
  end
  def after_inactive_sign_up_path_for(resource)
    new_staff_session_path
  end
end