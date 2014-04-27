class StudentPortal::BaseController < ApplicationController
  include StudentPortal::BaseHelper


  rescue_from CanCan::AccessDenied do |exception|
    redirect_to student_portal_root_path, :alert => exception.message

    $stderr.puts flash.to_hash
  end


end