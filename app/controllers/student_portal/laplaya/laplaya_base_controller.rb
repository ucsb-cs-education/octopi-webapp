require 'laplaya_module'
class StudentPortal::Laplaya::LaplayaBaseController < StudentPortal::BaseController
  protect_from_forgery with: :null_session
  before_action :signed_in_student
  before_action :setup_laplaya, only: [:laplaya, :laplaya_file]
  before_action :force_trailing_slash, only: [:laplaya]
  before_action :force_no_trailing_slash, only: [:laplaya_file]
  include LaplayaModule

  def laplaya
    laplaya_helper
  end

  def laplaya_file
    @laplaya_ide_params[:fileID] = params[:id]
    laplaya_helper
  end

end
