class Pages::AssessmentTasksController < Pages::TasksController
  load_and_authorize_resource
  load_and_authorize_resource :activity_page, only: [:new, :create]
  before_filter :set_page_variable

  # GET /activity/:id
  def show
  end

  def update
    ids = CGI.parse(params[:children_order])['assessment_question[]']
    updated = @assessment_task.update_with_children(assessment_task_params, ids)
    respond_to do |format|
      format.html do
        if updated
          redirect_to @assessment_task, notice: "Successfully updated"
        else
          render action: edit
        end
      end
      format.js do
        response.location = curriculum_page_url(@assessment_task)
        js false
        unless updated
          head :bad_request, location: curriculum_page_url(@assessment_task)
        end
      end
    end
  end

  def create
    @assessment_task.parent = @activity_page
    @assessment_task.save!
    respond_to do |format|
      format.html { redirect_to @activity_page }
      format.js {
        js false
      }
    end
  end

  def destroy
    @assessment_task.destroy
    flash[:success] = "Task #{@assessment_task.title} has been deleted."
    redirect_to @assessment_task.activity_page
  end

  def set_page_variable
    @page = @assessment_task if @assessment_task
    @pages = @assessment_tasks if @assessment_tasks
    # @page = @assessment_task.becomes(Task) if @assessment_task
    # @pages = @assessment_tasks.map{|x| x.becomes(Task)} if @assessment_tasks
  end

  def assessment_task_params
    params.require(:assessment_task).permit(:title, :'teacher_body', :'student_body')
  end
end