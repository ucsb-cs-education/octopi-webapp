class StudentPortal::Snap::SnapFilesController < StudentPortal::Snap::SnapBaseController
  load_and_authorize_resource

  def index
    @snap_files = SnapFile.with_role(:owner, current_user).distinct
    if signed_in_student?
      render :json => @snap_files.map { |x| {file_name: x.file_name, file_id: x.to_param, public: x.public, updated_at: x.updated_at, note: x.note, thumbnail: x.thumbnail} }
    else
      render :json => @snap_files.map { |x| {file_name: x.file_name, file_id: x.to_param, public: x.public, note: x.note} }
    end

  end

  def show
    render json: @snap_file, except: [:created_at, :thumbnail]
  end

  def update
    params = snap_file_params
    if params.any? && @snap_file.update_attributes(params)
      status = :no_content
    else
      status = :bad_request
    end
    head status, location: student_portal_snap_snap_file_url(@snap_file)
  end

  def create
    @snap_file = SnapFile.new(snap_file_params)
    if @snap_file.save
      current_user.add_role(:owner, @snap_file)
      create_post_success_response(:created, student_portal_snap_snap_file_url(@snap_file),@snap_file.file_id)
    else
      head :bad_request
    end
  end

  def destroy
    @snap_file.destroy
    head :no_content
  end

  private
  def snap_file_params
    avail_params = [:project, :media]
    if can? :create_public_snap_files, SnapFile
      avail_params << :public
    end
    params.require(:snap_file).permit(*avail_params)
  end

end
