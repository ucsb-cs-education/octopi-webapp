class StudentPortal::StaticPagesController < StudentPortal::BaseController
  before_filter :force_trailing_slash, only: 'laplaya'


  before_action :signed_in_student, only: [:home]
  before_action :temp_signed_in_student, only: [:laplaya]

  def home

  end

  def help
  end

  def laplaya
    render :layout => false
  end

  private
    def force_trailing_slash
      redirect_to request.original_url + '/' unless request.original_url.match(/\/$/)
    end

  #TODO: I don't like having this here. Infact, I don't like non-students accessing laplaya within the
  # student_portal/laplaya route. I would like to move that out, but unfortunately due to the way the static-assets
  # are loaded, I cannot do that until we move all of the laplaya javascript/image assets into the rails pipeline so that
  # we can use the controller in multiple places
  # additionally, we would need to remove the reliance on the student_portal base controller for laplaya
  # If we end up splitting laplaya into two versions at the javascript level, rather than using the erb pipeline,
  # then we can just leave this alone
    def temp_signed_in_student
      unless current_staff || current_student
        store_location
        flash.keep #Keep old flashes - since student_portal doesn't have a globally accessible home, if we redirect home,
        # as a logged out user, then we will redirect again, so we want to keep old warnings.
        flash[:warning] = 'Please sign in.'
        redirect_to student_portal_signin_path
      end
    end
end
