class Pages::ModulePagesController < Pages::PagesController
  load_and_authorize_resource
  load_and_authorize_resource :curriculum_page, only: [:new, :create]
  before_filter :set_page_variable

  # GET /modules/:id
  def show
    @user_laplaya_files = LaplayaFile.where(owner: current_user) if current_user.has_role? :super_staff
    @user_laplaya_files ||= LaplayaFile.accessible_by(current_ability, :index)
  end

  def update
    ids = CGI.parse(params[:children_order])['activity_page[]'] if params[:children_order].present?
    if ids
      updated = @module_page.update_with_children(module_page_params, ids)
    else
      updated = @module_page.update(module_page_params)
    end

    respond_to do |format|
      format.html do
        if updated
          redirect_to @module_page, notice: "Successfully updated"
        else
          render action: edit
        end
      end
      format.js do
        response.location = module_page_url(@module_page)
        js false
        unless updated
          head :bad_request, location: module_page_url(@module_page)
        end
      end
    end
  end

  def create

    begin
      ModulePage.transaction do
        @module_page.parent = @curriculum_page
        @module_page.save!
        @module_page.create_sandbox_base_laplaya_file(file_name: 'New Project')
        @module_page.create_project_base_laplaya_file(file_name: 'New Project')
        @module_page.save!
      end
    rescue ActiveRecord::RecordInvalid
      render text: @module_page.errors, status: :bad_request
      return
    end
    respond_to do |format|
      format.html { redirect_to @curriculum_page }
      format.js {
        js false
        render status: :created
      }
    end
  end

  def destroy
    @module_page.destroy
    flash[:success] = "Module #{@module_page.title} has been deleted."
    redirect_to @module_page.curriculum_page
  end

  def clone_project
    clone_helper(@module_page.project_base_laplaya_file)
  end

  def clone_sandbox
    clone_helper(@module_page.sandbox_base_laplaya_file)
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
    redirect_to @module_page
  end

  def set_page_variable
    @page = @module_page
    @pages = @module_pages
  end

  def module_page_params
    params.require(:module_page).permit(:title, :'teacher_body', :'student_body', :'designer_note')
  end
end
