class StudentPortal::Snap::SnapFilesController < StudentPortal::Snap::SnapBaseController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.json {
        render :json => @snap_files.map { |x| {file_name: x.file_name, file_id: x.to_param, public: x.public, updated_at: x.updated_at}}
      }
    end

  end

  def show
    respond_with @snap_file
  end

  def update
    status = :bad_request
    respond_to do |format|
      format.xml {
        status = :no_content if @snap_file.update_attributes(xml: request.body.read)
      }
      format.json {
        status = :no_content if @snap_file.update_attributes(snap_file_params)
      }
    end

    head status, location: student_portal_snap_snap_file_url(@snap_file, format: :xml)
  end

  def create
    respond_to do |format|
      format.xml {
        @snap_file = SnapFile.new(xml: request.body.read)
      }
      format.json {
        @snap_file = SnapFile.new(snap_file_params)
      }
    end
    if @snap_file.save
      current_user.add_role(:owner, @snap_file)
      create_post_success_response(:created, student_portal_snap_snap_file_url(@snap_file, format: :xml))
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
    result = params.require(:snap_file).permit(:file_name, :xml, :public)
    if cannot? :create_public_snap_file, SnapFile
      result.delete(:public)
    end
    result
  end

end
