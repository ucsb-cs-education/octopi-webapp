class StudentPortal::Laplaya::LaplayaFilesController < StudentPortal::Laplaya::LaplayaBaseController
  load_and_authorize_resource

  def index
    if current_user
      @laplaya_files = LaplayaFile.with_role(:owner, current_user).distinct
    end
    render :json => @laplaya_files, each_serializer: LaplayaFileIndexSerializer
  end

  def show
    render json: @laplaya_file, except: [:created_at, :thumbnail]
  end

  def update
    params = laplaya_file_params
    if params.any? && @laplaya_file.update_attributes(params)
      status = :no_content
    else
      status = :bad_request
    end
    head status, location: laplaya_file_url(@laplaya_file)
  end

  def create
    @laplaya_file = LaplayaFile.new(laplaya_file_params)
    if @laplaya_file.save
      current_user.add_role(:owner, @laplaya_file)
      create_post_success_response(:created, laplaya_file_url(@laplaya_file),@laplaya_file.id)
    else
      head :bad_request
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
