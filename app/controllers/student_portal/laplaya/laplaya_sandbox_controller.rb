class StudentPortal::Laplaya::LaplayaSandboxController < StudentPortal::Laplaya::LaplayaFilesController
  before_action :signed_in_student
  before_action :load_module
  # authorize_resource :laplaya_file
  js false

  def index
    #Following line needed to prevent super_staff from crashing server during index
    @laplaya_files = ::StudentResponse::SandboxResponseLaplayaFile.where(module_page: @module_page).where(owner: current_user)
    render json: @laplaya_files, each_serializer: LaplayaFileIndexSerializer
  end

  def create
    @laplaya_file = ::StudentResponse::SandboxResponseLaplayaFile.new(laplaya_file_params)
    @laplaya_file.owner = current_user
    if @laplaya_file.save
      create_post_success_response(:created, laplaya_file_url(@laplaya_file), @laplaya_file.id)
    else
      render text: @laplaya_file.errors, status: :bad_request
    end
  end

  private
  def laplaya_file_params
    avail_params = [:project, :media]
    if can? :create_public_laplaya_files, LaplayaFile
      avail_params << :public
    end
    result = params.require(:laplaya_file).permit(*avail_params)
    result[:module_page] = @module_page
    result
  end

  def load_module
    @module_page = @module_page = ModulePage.find(params[:module_page_id])
    unless in_valid_module?
      render :bad_request
      false
    end
  end

  def in_valid_module?
    @module_page && current_school_class.module_pages.include?(@module_page)
  end

end
