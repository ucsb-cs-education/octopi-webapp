class Pages::AssessmentTasksController < Pages::TasksController
  load_and_authorize_resource
  load_and_authorize_resource :activity_page, only: [:new, :create]
  before_filter :set_page_variable

  # GET /activity/:id
  def show
    @task_dependencies = @assessment_task.task_dependencies
    @activity_dependants = @assessment_task.activity_dependants
    @task_dependants = @assessment_task.dependants
    @relatable_tasks = Task.where(activity_page: @assessment_task.activity_page.module_page.activity_pages).where.not(id: @assessment_task.prerequisites.pluck(:id)<<@assessment_task.id)
  end

  def update
    ids = nil
    ids = CGI.parse(params[:children_order])['assessment_question[]'] if params[:children_order].present?
    if ids
      updated = @assessment_task.update_with_children(assessment_task_params, ids)
    else
      updated = @assessment_task.update(assessment_task_params)
    end

    respond_to do |format|
      format.js do
        response.location = assessment_task_url(@assessment_task)
        js false
        unless updated
          bad_request_with_errors @assessment_task, assessment_task_url(@assessment_task)
        end
      end
    end
  end

  def create
    @assessment_task.parent = @activity_page
    if @assessment_task.save
      respond_to do |format|
        format.js {
          js false
          render status: :created
        }
      end
    else
      bad_request_with_errors @assessment_task
    end
  end

  def delete_all_responses
    begin
      if @assessment_task.delete_all_responses!
        flash[:success]="All responses successfully deleted."
      end
    rescue Exception => e
      flash[:danger]=e.message
    end
    redirect_to assessment_task_path(@assessment_task)
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
    params.require(:assessment_task).permit(:title, :teacher_body, :student_body, :designer_note, :visible_to, :special_attributes)
  end
end
