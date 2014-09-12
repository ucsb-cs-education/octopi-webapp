require 'student_signin_module'
class ApplicationController < ActionController::Base
  include StudentSigninModule
  before_filter :set_cache_buster, only: [:index]

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  def set_staff_laplaya_file_base_path
    @laplaya_ide_params[:pushStateBase] = staff_laplaya_path + '/'
  end

  def exception_redirect_path(login_dependent=false)
    if staff_signed_in? || !login_dependent
      main_app.root_path
    else
      main_app.new_staff_session_path
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        redirect_to exception_redirect_path(true), :alert => exception.message
      end
      format.js do
        head :forbidden
      end
      format.json do
        head :forbidden
      end
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.html do
        redirect_to exception_redirect_path, :alert => exception.message
      end
      format.js do
        render text: exception.message, status: 404
      end
      format.json do
        render text: exception.message, status: 404
      end
    end
  end

  def current_user
    current_staff
  end

  def user_for_paper_trail
    if staff_signed_in?
      current_staff.id
    elsif signed_in_student?
      current_student.id
    else
      'User not logged in'
    end
  end

  def bad_request_with_errors(model, location = nil)
    js false
    if location
      render text: model.errors.full_messages, status: :bad_request, location: location
    else
      render text: model.errors.full_messages, status: :bad_request
    end
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, :super_staff, :school_admin, :teacher, :first_name, :last_name, roles: [], role_ids: [], school_id: []) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :super_staff, :school_admin, :teacher, :password, :password_confirmation, :first_name, :last_name, :current_password, roles: [], role_ids: [], school_id: []) }
  end

  def set_cache_buster
    if self.is_a?(TaskResponsesController)
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
  end

end
