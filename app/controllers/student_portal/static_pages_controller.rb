class StudentPortal::StaticPagesController < StudentPortal::BaseController

  before_action :signed_in_student, only: [:home]

  def home
  end

  def help
  end

end
