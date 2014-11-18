require 'student_signin_module'
class Staff::SessionsController < Devise::SessionsController
  include StudentSigninModule

  def after_sign_in_path_for(resource)
    if action_name == 'new'
      redirect_url = staff_root_path
    else
      protocol = (Rails.env.production?) ? 'https' : 'http'
      sign_in_url = url_for(:action => 'new', :controller => 'sessions', :only_path => false, protocol: protocol)
      redirect_url = stored_location_for(resource) || request.referer || staff_root_path
      redirect_url = super if redirect_url == sign_in_url
      redirect_url = staff_root_path if redirect_url == sign_in_url
    end
    redirect_url
  end

  def create
    super do
      sign_out_student(current_student) if signed_in_student?
    end
  end

  def destroy
    original_user = get_original_user
    session.delete(REMEMBER_USER_KEY)
    super
    if original_user
      flash[:notice] = 'Your original session has been restored'
      sign_in original_user
    end
  end

  def sign_out(*args)
    super(*args)
    if signed_in_student? && current_student.is_a?(TestStudent)
      sign_out_student
    end
  end

  def switch_user
    unless current_staff && current_staff.super_staff?
      head :unauthorized and return
    end
    user = User.find(params[:user_id])
    if params[:remember] == 'true'
      remember_user
    end
    sign_out :staff
    if user.is_a? Staff
      sign_in user
    else
      sign_in_student(user, user.school_classes.find(params[:school_class_id]))
    end
    flash[:notice] = 'You have successfuly switched to another user'
    redirect_to (request.referrer || root_path)
  end


end