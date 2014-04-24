class StudentPortal::Snap::SnapFilesController < StudentPortal::BaseController
  before_filter :decode_id
  load_and_authorize_resource

  def show
    respond_to do |format|
      format.xml {
        render :xml => SnapFile.find(params[:id]).xml
      }
    end
  end

end
