class Pages::ActivityPagesController < Pages::PagesController
  load_and_authorize_resource
  load_and_authorize_resource :module_page, only: [:new, :create]
  before_filter :set_page_variable

  # GET /activity/:id
  def show
  end

  def sort
    @activity_page.update_children_order(params[:task])
    render nothing: true
  end

  def set_page_variable
    @page = @activity_page
    @pages = @activity_pages
  end

end
