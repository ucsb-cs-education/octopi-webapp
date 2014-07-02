class Pages::AssessmentTasksController < Pages::TasksController
  load_and_authorize_resource
  load_and_authorize_resource :activity_page, only: [:new, :create]
  before_filter :set_page_variable

  # GET /activity/:id
  def show
  end

  def create
    @assessment_task.parent = @activity_page
    @assessment_task.update_attributes({title: 'New Assessment Task', teacher_body: '<p></p>', student_body: '<p></p>'})
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

  def assessment_params
    params.require(:assessment_task).permit(:title, :'teacher_body', :'student_body')
  end
end
