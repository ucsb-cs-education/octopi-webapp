class Pages::ActivityPagesController < Pages::PagesController
  load_and_authorize_resource
  load_and_authorize_resource :module_page, only: [:new, :create]
  before_filter :set_page_variable

  # GET /activity/:id
  def show
    @activity_dependencies = @activity_page.activity_dependencies
    @relatable_tasks = Task.where(activity_page: (ModulePage.find(@activity_page.module_page).activity_pages)) - (@activity_page.prerequisites.to_ary.concat(@activity_page.children))
  end

  def update
    ids = nil
    ids = CGI.parse(params[:children_order].
                        gsub(/(laplaya|assessment|offline)_/,''))['task[]'] if params[:children_order].present?

    if ids
      updated = @activity_page.update_with_children(activity_page_params, ids)
    else
      updated = @activity_page.update(activity_page_params)
    end

    respond_to do |format|
      format.js do
        response.location = activity_page_url(@activity_page)
        js false
        unless updated
          head :bad_request, location: activity_page_url(@activity_page)
        end
      end
    end
  end

  def destroy
    @activity_page.destroy
    flash[:success] = "Activity #{@activity_page.title} has been deleted."
    redirect_to @activity_page.module_page
  end

  def create
    @activity_page.parent = @module_page
    if @activity_page.save
      respond_to do |format|
        format.html { redirect_to @module_page }
        format.js {
          js false
          render status: :created
        }
      end
    else
      render text: @activity_page.errors, status: :bad_request
    end


  end

  private

  def set_page_variable
    @page = @activity_page
    @pages = @activity_pages
  end

  def activity_page_params
    params.require(:activity_page).permit(:title, :'teacher_body', :'student_body', :'designer_note')
  end

end
