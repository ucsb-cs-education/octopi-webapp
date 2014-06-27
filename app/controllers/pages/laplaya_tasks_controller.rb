class Pages::LaplayaTasksController < Pages::TasksController
  load_and_authorize_resource
  load_and_authorize_resource :activity_page, only: [:new, :create]
  before_filter :set_page_variable

  # GET /activity/:id
  def show
    @user_laplaya_files = LaplayaFile.accessible_by(current_ability, :index)
  end

  def create
    @laplaya_task.parent = @activity_page
    @laplaya_task.update_attributes({title: 'New Task', teacher_body: '<p></p>', student_body: '<p></p>'})
    laplaya_file = TaskBaseLaplayaFile.new_base_file(@laplaya_task)
    respond_to do |format|
      format.html { redirect_to @laplaya_task }
      format.js {
        js false
      }
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

end
