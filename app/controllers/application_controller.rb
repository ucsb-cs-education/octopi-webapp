require 'IdCrypt'

class ApplicationController < ActionController::Base


  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      redirect_to main_app.root_url, :alert => exception.message
    else
      redirect_to main_app.new_user_session_url, :alert => exception.message
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    redirect_to main_app.root_url, :alert => exception.message
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, :first_name, :last_name) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :password, :password_confirmation, :first_name, :last_name, :current_password) }
  end

  def decode_id
    params[:id] = IdCrypt::decode_id(params[:id]).to_s if params[:id]
  end


end
