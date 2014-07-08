class Pages::ModulePagesController < Pages::PagesController
  load_and_authorize_resource
  load_and_authorize_resource :curriculum_page, only: [:new, :create]
  before_filter :set_page_variable

  # GET /modules/:id
  def show
  end

  def update
    ids = CGI.parse(params[:children_order])['activity_page[]']
    updated = @module_page.update_with_children(module_page_params, ids)
    respond_to do |format|
      format.html do
        if updated
          redirect_to @module_page, notice: "Successfully updated"
        else
          render action: edit
        end
      end
      format.js do
        response.location = module_page_url(@module_page)
        js false
        unless updated
          head :bad_request, location: module_page_url(@module_page)
        end
      end
    end
  end

  def create
    @module_page.parent = @curriculum_page
    if @module_page.save
      respond_to do |format|
        format.html { redirect_to @curriculum_page }
        format.js {
          js false
          render status: :created
        }
      end
    else
      render text: @module_page.errors, status: :bad_request
    end
  end

  def destroy
    @module_page.destroy
    flash[:success] = "Module #{@module_page.title} has been deleted."
    redirect_to @module_page.curriculum_page
  end

  private
  def set_page_variable
    @page = @module_page
    @pages = @module_pages
  end

  def module_page_params
    params.require(:module_page).permit(:title, :'teacher_body', :'student_body')
  end
end
