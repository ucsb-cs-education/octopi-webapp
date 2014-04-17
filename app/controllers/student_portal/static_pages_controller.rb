class StudentPortal::StaticPagesController < StudentPortal::BaseController


  rescue_from CanCan::AccessDenied do |exception|
    redirect_to student_portal_, :notice => exception.message
  end

  before_action :signed_in_student, only: [:home]

  def home

  end

  def help
  end
end
