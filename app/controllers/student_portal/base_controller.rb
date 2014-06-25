class StudentPortal::BaseController < ApplicationController
  include StudentPortal::BaseHelper
  after_action :update_autosignout_time
  alias_method :current_user, :current_student


  rescue_from CanCan::AccessDenied do |exception|
    redirect_to student_portal_root_path, :alert => exception.message

    $stderr.puts flash.to_hash
  end

  def current_user
    current_student
  end

end