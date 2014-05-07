class StudentPortal::Snap::SnapFilesController < StudentPortal::BaseController
  before_filter :decode_id, only: [:show, :update, :create, :destroy]  
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.json {
        render :json => @snap_files.map { |x| {ProjectName: x.id_encoded.to_s, Public: x.sample_file}}
      }
    end

  end

  def show
    respond_to do |format|
      format.xml {
        render :xml => @snap_file.xml
      }
    end
  end

  def update

  end

  def create
    @snap_file = SnapFile.new(snapfile_params)
    #Might need to add School.with_role(:school_admin, current_user).pluck(:id).includes(@student.school_id) && , lets chcek
    status = nil
    if @snap_file.save
      current_user.add_role(:owner, @snap_file)
      status = :created
    else
      status = :bad_request
    end
    render :nothing => true, :status => status, :content_type => 'text/html'
  end

  def destroy

  end

  private
  def snapfile_params
    if can? :create_sample_snapfile, SnapFile
      params.require(:snapfile).permit(:xml, :sample_file)
    else
      params.require(:snapfile).permit(:xml)
    end
  end

  alias_method :devise_current_user, :current_user

  def current_user
    current_student || devise_current_user
  end

end
