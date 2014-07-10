class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

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

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, :first_name, :last_name) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :password, :password_confirmation, :first_name, :last_name, :current_password) }
  end

end
