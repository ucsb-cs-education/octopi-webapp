class Pages::TasksController < Pages::PagesController
  load_and_authorize_resource
  load_and_authorize_resource :activity_page, only: [:new, :create]
  before_filter :set_page_variable

  # GET /activity/:id
  def show
  end

  def set_page_variable
    @page = @task
    @pages = @tasks
  end

end
