class Pages::ActivityPagesController < Pages::PagesController
  load_and_authorize_resource
  load_and_authorize_resource :module_page, only: [:new, :create]
  before_filter :set_page_variable

  # GET /activity/:id
  def show
  end

  def update
    ids = CGI.parse(params[:children_order].gsub("laplaya_task","task").gsub("assessment_task","task"))['task[]']
    updated = @activity_page.update_with_children(activity_page_params, ids)
    respond_to do |format|
      format.html do
        if updated
          redirect_to @activity_page, notice: "Successfully updated"
        else
          render action: edit
        end
      end
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
    @activity_page.save!
    respond_to do |format|
      format.html { redirect_to @module_page }
      format.js {
        js false
      }
    end
  end

  private

  def set_page_variable
    @page = @activity_page
    @pages = @activity_pages
  end

  def activity_page_params
    params.require(:activity_page).permit(:title, :'teacher_body', :'student_body')
  end

end