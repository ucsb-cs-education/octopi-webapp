class Pages::ModulePagesController < Pages::PagesController
  load_and_authorize_resource
  load_and_authorize_resource :curriculum_page, only: [:new, :create]
  before_filter :set_page_variable

  # GET /modules/:id
  def show
  end

  def sort
    @module_page.update_children_order(params[:activity_page])
    render nothing: true
  end

  def set_page_variable
    @page = @module_page
    @pages = @module_pages
  end

end
