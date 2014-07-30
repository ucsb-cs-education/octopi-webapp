class Pages::LaplayaTasksController < Pages::TasksController
  load_and_authorize_resource
  load_and_authorize_resource :activity_page, only: [:new, :create]
  before_filter :set_page_variable
  # GET /activity/:id
  def show
    @user_laplaya_files = LaplayaFile.where(owner: current_user) if current_user.has_role? :super_staff
    @user_laplaya_files ||= LaplayaFile.accessible_by(current_ability, :index)

    @task_dependencies = @laplaya_task.task_dependencies
    @activity_dependants = @laplaya_task.activity_dependants
    @task_dependants = @laplaya_task.dependants
    @relatable_tasks = Task.where(activity_page: ModulePage.find(@laplaya_task.activity_page.module_page).activity_pages) - (@laplaya_task.prerequisites.to_ary.push(@laplaya_task))

    @laplaya_analysis_file = @laplaya_task.laplaya_analysis_file
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
          render text: @laplaya_task.errors, status: :bad_request, location: laplaya_file_url(@laplaya_task)
        end
      end
    end
  end

  def create
    begin
      LaplayaTask.transaction do
        @laplaya_task.parent = @activity_page
        @laplaya_task.save!
        @laplaya_task.create_task_base_laplaya_file(file_name: 'New Project')
        @laplaya_task.create_task_completed_laplaya_file(file_name: 'New Project Solution')
        @laplaya_task.create_laplaya_analysis_file
        @laplaya_task.save!
      end
    rescue ActiveRecord::RecordInvalid
      render text: @laplaya_task.errors, status: :bad_request
      return
    end
    respond_to do |format|
      format.html { redirect_to @laplaya_task }
      format.js {
        js false
        response.status = :created
      }
    end
  end

  def destroy
    @laplaya_task.destroy
    flash[:success] = "Task #{@laplaya_task.title} has been deleted."
    redirect_to @laplaya_task.activity_page
  end

  def clone
    clone_helper(@laplaya_task.task_base_laplaya_file)
  end

  def clone_completed
    clone_helper(@laplaya_task.task_completed_laplaya_file)
  end

  def update_laplaya_analysis_file
    data = params[:laplaya_analysis_file][:data].read
    @laplaya_task.laplaya_analysis_file.update_attributes!(data: data)
    flash[:success] = "Laplaya analysis file successfully uploaded."
    redirect_to @laplaya_task
  end

  def get_laplaya_analysis_file
    send_data @laplaya_task.laplaya_analysis_file.data, filename: "processor_#{@laplaya_task.id}.js.txt", disposition: :attachment
  end

  private
  def clone_helper(file_to_clone_to)
    if params[:laplaya_file] && params[:laplaya_file][:laplaya_file] && params[:laplaya_file][:laplaya_file].present?
      laplaya_file = LaplayaFile.find(params[:laplaya_file][:laplaya_file])
      authorize! :show, laplaya_file
      file_to_clone_to.clone(laplaya_file)
      flash[:success] = "Laplaya File successfully cloned!"
    else
      flash[:danger] = "Invalid selection for Laplaya File cloning!"
    end
    redirect_to @laplaya_task
  end

  def set_page_variable
    @page = @laplaya_task if @laplaya_task
    @pages = @laplaya_tasks if @laplaya_tasks
  end

  def laplaya_task_params
    params.require(:laplaya_task).permit(:title, :teacher_body, :student_body, :'designer_note')
  end

end
