class Pages::CurriculumPagesController < Pages::PagesController
  load_and_authorize_resource
  before_filter :set_page_variable

  # GET /curriculums
  def index
  end

  # GET /curriculums/:id
  def show
  end

  def update
    ids = nil
    ids = CGI.parse(params[:children_order])['module_page[]'] if params[:children_order].present?
    if ids
      updated = @curriculum_page.update_with_children(curriculum_page_params, ids)
    else
      updated = @curriculum_page.update(curriculum_page_params)
    end

    respond_to do |format|
      format.js do
        response.location = curriculum_page_url(@curriculum_page)
        js false
        unless updated
          bad_request_with_errors @curriculum_page, curriculum_page_url(@curriculum_page)
        end
      end
    end
  end

  private
  def set_page_variable
    @page = @curriculum_page
    @pages = @curriculum_pages
  end

  def curriculum_page_params
    params.require(:curriculum_page).permit(:title, :'teacher_body', :'student_body', :'designer_note')
  end

end
