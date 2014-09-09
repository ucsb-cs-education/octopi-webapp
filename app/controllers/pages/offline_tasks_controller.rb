class Pages::OfflineTasksController < Pages::TasksController
  load_and_authorize_resource
  load_and_authorize_resource :activity_page, only: [:new, :create]
  before_filter :set_page_variable
  # GET /activity/:id
  def show
    @task_dependencies = @offline_task.task_dependencies
    @activity_dependants = @offline_task.activity_dependants
    @task_dependants = @offline_task.dependants
    @relatable_tasks = Task.where(activity_page: @offline_task.activity_page.module_page.activity_pages) - (@offline_task.prerequisites.to_ary.push(@offline_task))

  end

  def update
    updated = @offline_task.update(offline_task_params)
    respond_to do |format|
      format.js do
        js false
        unless updated
          bad_request_with_errors @offline_task, offline_task_url(@offline_task)
        end
      end
    end
  end

  def create
    begin
      LaplayaTask.transaction do
        @offline_task.parent = @activity_page
        @offline_task.save!
      end
    rescue ActiveRecord::RecordInvalid
      bad_request_with_errors @offline_task
      return
    end
    respond_to do |format|
      format.js {
        js false
        response.status = :created
      }
    end
  end

  def destroy
    @offline_task.destroy
    flash[:success] = "Task #{@offline_task.title} has been deleted."
    redirect_to @offline_task.activity_page
  end


  private

  def set_page_variable
    @page = @offline_task if @offline_task
    @pages = @offline_tasks if @offline_tasks
  end

  def offline_task_params
    params.require(:offline_task).permit(:title, :teacher_body, :student_body, :designer_note, :visible_to, :special_attributes)
  end

end
