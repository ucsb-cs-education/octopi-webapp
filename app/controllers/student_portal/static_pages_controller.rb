class StudentPortal::StaticPagesController < StudentPortal::BaseController
  before_filter :force_trailing_slash, only: 'snap'


  rescue_from CanCan::AccessDenied do |exception|
    redirect_to student_portal_, :notice => exception.message
  end

  before_action :signed_in_student, only: [:home]

  def home

  end

  def help
  end

  def snap
    render :layout => false
  end

  private
    def force_trailing_slash
      redirect_to request.original_url + '/' unless request.original_url.match(/\/$/)
    end
end
