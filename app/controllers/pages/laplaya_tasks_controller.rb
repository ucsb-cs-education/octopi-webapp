class Pages::LaplayaTasksController < Pages::TasksController
  load_and_authorize_resource
  load_and_authorize_resource :activity_page, only: [:new, :create]
  before_filter :set_page_variable

  # GET /activity/:id
  def show
    @user_laplaya_files = LaplayaFile.accessible_by(current_ability, :index)
  end

  def update
    updated = @laplaya_task.update(laplaya_task_params)
    respond_to do |format|
      format.html do
        if updated
          redirect_to @laplaya_task, notice: 'Task was successfully updated.'
        else
          render action: 'edit'
        end
      end
      format.js do
        response.location = laplaya_file_url(@laplaya_task)
        js false
        unless updated
          head :bad_request, location: laplaya_file_url(@laplaya_task)
        end
      end
    end
  end

  def create
    LaplayaTask.transaction do
      @laplaya_task.parent = @activity_page
      if @laplaya_task.save
        respond_to do |format|
          format.html { redirect_to @laplaya_task }
          format.js {
            js false
            render status: :created
          }
        end
      else
        render text: @laplaya_task.errors, status: :bad_request
      end
      laplaya_file = TaskBaseLaplayaFile.new_base_file(@laplaya_task)
    end
  end

  def destroy
    @laplaya_task.destroy
    flash[:success] = "Task #{@laplaya_task.title} has been deleted."
    redirect_to @laplaya_task.activity_page
  end

  def clone
    laplaya_file = LaplayaFile.find(params[:laplaya_file][:laplaya_file])
    authorize! :show, laplaya_file
    @laplaya_task.task_base_laplaya_file.clone(laplaya_file)
    flash[:success] = "Laplaya File successfully cloned!"
    redirect_to @laplaya_task
  end

  private
  def set_page_variable
    @page = @laplaya_task if @laplaya_task
    @pages = @laplaya_tasks if @laplaya_tasks
  end

  def laplaya_task_params
    params.require(:laplaya_task).permit(:title, :'teacher_body', :'student_body')
  end
end
