class StudentPortal::Snap::SnapFilesController < StudentPortal::Snap::SnapBaseController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.json {
        render :json => @snap_files.map { |x| {ProjectName: x.to_param, Public: x.public}}
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

    head status, location: student_portal_snap_snap_file_path(@snap_file, format: :xml)
  end

  def create
    status = :bad_request
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
      status = :created
    end
    # render :nothing => true, :status => status, :content_type => 'text/html'
    # respond_with(, location: student_portal_snap_snap_file_path(@snap_file))
    head status, location: student_portal_snap_snap_file_path(@snap_file, format: :xml)
  end

  def destroy
    @snap_file.destroy
    head :no_content
  end

  private
  def snap_file_params
    if can? :create_public_snapfile, SnapFile
      params.require(:snapfile).permit(:xml, :public)
    else
      params.require(:snapfile).permit(:xml)
    end
  end
end
