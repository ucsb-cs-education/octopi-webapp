class StudentPortal::Laplaya::LaplayaFilesController < StudentPortal::Laplaya::LaplayaBaseController
  load_and_authorize_resource
  js false

  def index
    #Following line needed to prevent super_staff from crashing server during index
    @laplaya_files = LaplayaFile.with_role(:owner, current_user) if current_user.has_role? :super_staff

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
    if @laplaya_file.save
      current_user.add_role(:owner, @laplaya_file)
      create_post_success_response(:created, laplaya_file_url(@laplaya_file),@laplaya_file.id)
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

end
