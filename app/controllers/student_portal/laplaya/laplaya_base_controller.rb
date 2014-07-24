class StudentPortal::Laplaya::LaplayaBaseController < StudentPortal::BaseController
  protect_from_forgery with: :null_session
  before_action :force_trailing_slash, only: [:laplaya]
  before_action :force_no_trailing_slash, only: [:laplaya_file]
  before_action :build_session_params
  before_action :set_fileid_in_session, only: [:laplaya_file]
  before_action :build_laplaya_params, only: [:laplaya, :laplaya_file]
  before_action :temp_signed_in_student, only: [:laplaya]
  respond_to :json

  def laplaya
    js false
    render layout: false
  end

  def laplaya_file
    # redirect_to student_portal_laplaya_path
    render 'laplaya', layout: false
  end

  private
  def build_session_params
    session[:laplaya_params] ||= {}
  end

  def set_fileid_in_session
    session[:laplaya_params][:fileID] = params[:id]
  end

  def build_laplaya_params
    laplaya_ide_params = session[:laplaya_params]
    session.delete(:laplaya_params)
    if staff_signed_in? && Ability.new(current_staff).can?(:see_developer_view, LaplayaFile)
      laplaya_ide_params['developerMode'] = true
    end
    laplaya_ide_params['root_path'] = '/static/laplaya/'
    @laplaya_ide_params = laplaya_ide_params.to_json
  end

  def force_no_trailing_slash
    force_slash :noslash
  end

  def force_trailing_slash
    force_slash :slash
  end

  def force_slash(slash = :slash)
    if slash == :slash
      redirect_to request.original_url + '/' unless request.original_url.match(/\/$/)
    elsif slash == :noslash
      redirect_to request.original_url.gsub /\/+$/, '' unless request.original_url.match(/[^\/]$/)
    end
  end

  #TODO: I don't like having this here. Infact, I don't like non-students accessing laplaya within the
  # student_portal/laplaya route. I would like to move that out, but unfortunately due to the way the static-assets
  # are loaded, I cannot do that until we move all of the laplaya javascript/image assets into the rails pipeline so that
  # we can use the controller in multiple places
  # additionally, we would need to remove the reliance on the student_portal base controller for laplaya
  # If we end up splitting laplaya into two versions at the javascript level, rather than using the erb pipeline,
  # then we can just leave this alone
  def temp_signed_in_student
    unless current_user
      store_location
      flash.keep #Keep old flashes - since student_portal doesn't have a globally accessible home, if we redirect home,
      # as a logged out user, then we will redirect again, so we want to keep old warnings.
      flash[:warning] = 'Please sign in.'
      redirect_to student_portal_signin_path
    end
  end

  def current_user
    current_student || current_staff
  end

  protected
  def create_post_success_response (status, location, file_id)
    render json: {success: true, location: location, file_id: file_id}, location: location, status: status
  end

end
