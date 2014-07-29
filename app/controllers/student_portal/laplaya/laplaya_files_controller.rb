class StudentPortal::Laplaya::LaplayaFilesController < StudentPortal::Laplaya::LaplayaBaseController
  load_and_authorize_resource :laplaya_file
  before_action :confirm_unlocked, only: [:show, :update]
  js false

  def index
    #Following line needed to prevent super_staff from crashing server during index
    @laplaya_files = LaplayaFile.where(owner: current_user) if current_user && current_user.has_role?(:super_staff)
    render json: @laplaya_files, each_serializer: LaplayaFileIndexSerializer
  end

  def show
    @laplaya_file = @laplaya_file.becomes(LaplayaFile)
    render json: @laplaya_file
  end

  def update
    params = laplaya_file_params
    if params.any? && @laplaya_file.update_attributes(params)
      head :no_content, location: laplaya_file_url(@laplaya_file)
    else
      render text: @laplaya_file.errors, status: :bad_request
    end
  end

  def create
    @laplaya_file.owner = current_user
    if @laplaya_file.save
      create_post_success_response(:created, laplaya_file_url(@laplaya_file), @laplaya_file.id)
    else
      render text: @laplaya_file.errors, status: :bad_request
    end
  end

  def destroy
    @laplaya_file.destroy
    head :no_content
  end

  private
  def laplaya_file_params
    avail_params = [:project, :media]
    if can? :create_public_laplaya_files, LaplayaFile
      avail_params << :public
    end
    params.require(:laplaya_file).permit(*avail_params)
  end

  def confirm_unlocked
    case @laplaya_file.type
      when 'StudentResponse::TaskResponseLaplayaFile'
        unless @laplaya_file.laplaya_task_response.task.is_accessible?(current_student, current_school_class)
          raise CanCan::AccessDenied
        end
      when 'StudentResponse::ProjectResponseLaplayaFile',
          'StudentResponse::SandboxResponseLaplayaFile',
          'SandboxBaseLaplayaFile'
        unless current_school_class.module_pages.include?(@laplaya_file.module_page)
          raise CanCan::AccessDenied
        end
      else
        # type code here
    end
  end

end
