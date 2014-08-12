class StudentPortal::StaticPagesController < StudentPortal::BaseController
  before_action :signed_in_student, only: [:home]

  def home
    @path = path_for_returning_student
    if @path.nil?
      flash.now[:error] = 'Your current class has no modules for students!'
    end
  end

  def help
    redirect_to help_path
  end

end
