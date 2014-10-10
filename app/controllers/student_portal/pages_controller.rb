require 'laplaya_module'
class StudentPortal::PagesController < StudentPortal::BaseController
  include LaplayaModule
  include ::Pages::PagesHelper

  before_action :force_no_trailing_slash, only: [:laplaya_task, :laplaya_sandbox_file, :design_thinking_project]
  before_action :force_trailing_slash, only: [:laplaya_sandbox]
  before_action :signed_in_student
  before_action :load_variables
  before_action :verify_valid_module, unless: :json_request?
  before_action :verify_valid_activity, only: [
      :activity_page,
      :laplaya_task,
      :assessment_task,
      :offline_task,
      :laplaya_task_response,
      :assessment_response
  ], unless: :json_request?
  before_action :verify_valid_task, only: [
      :laplaya_task,
      :assessment_task,
      :laplaya_task_response,
      :assessment_response,
      :offline_task
  ], unless: :json_request?
  before_action :build_laplaya_task_response, only: [
      :laplaya_task,
      :laplaya_task_response
  ], unless: :json_request?
  before_action :setup_laplaya, only: [:laplaya_task, :laplaya_sandbox, :laplaya_sandbox_file, :design_thinking_project],
                unless: :json_request?

  after_action :set_module_cookie, only: [:module_page]

  #GET /student_portal/modules/:id
  #student_portal_module_path
  def module_page
    respond_to do |format|
      format.html do
        @activity_pages = @module_page.activity_pages.student_visible
        @unlocks = Unlock.find_for(current_student, current_school_class, @activity_pages)
      end
    end
  end

  #GET /student_portal/activities/:id
  #student_portal_activity_path
  def activity_page
    # we should try to do some eager loading. It'd make things faster. But I don't think this works
    # @tasks = @activity_page.tasks.includes(:unlocks).where("unlocks.student_id" => current_student.id, "unlocks.school_class_id" => current_school_class.id)
    respond_to do |format|
      format.html do
        @tasks = @activity_page.tasks.student_visible
      end
    end
  end

  #GET /student_portal/offline_tasks/:id
  #student_portal_offline_task_path
  def offline_task
    respond_to do |format|
      format.html do
      end
      format.json do
        unlocked = @offline_task.get_visibility_status_for(current_student, current_school_class) != :locked
        render json: {unlocked: unlocked}
      end
    end
  end

  #GET /student_portal/assessment_tasks/:id
  #student_portal_assessment_task_path
  def assessment_task
    respond_to do |format|
      format.html do
        @task_response = AssessmentTaskResponse.new(
            student: current_student,
            school_class: current_school_class,
            task: @assessment_task)
        @assessment_task.children.each do |x|
          @task_response.assessment_question_responses.build(assessment_question: x)
        end
      end
      format.json do
        unlocked = @assessment_task.get_visibility_status_for(current_student, current_school_class) != :locked
        render json: {unlocked: unlocked}
      end
    end
  end

  #GET /student_portal/laplaya_tasks/:id
  #student_portal_laplaya_task_path
  def laplaya_task
    respond_to do |format|
      format.html do
        if @laplaya_task.demo?
          @laplaya_ide_params[:fileID] = @laplaya_task.task_completed_laplaya_file.id
          @laplaya_ide_params[:demoMode] = true
        else
          @laplaya_ide_params[:fileID] = @laplaya_task_response.laplaya_file.id
          @laplaya_ide_params[:parentHash] = @laplaya_task_response.laplaya_file.save_uuid
        end
        @laplaya_ide_params[:prevTask] = get_path_for_task(@laplaya_task.higher_item)
        @laplaya_ide_params[:nextTask] = get_path_for_task(@laplaya_task.lower_item)
        @laplaya_ide_params[:returnPath] = student_portal_activity_path(@activity_page)
        laplaya_helper
      end
      format.json do
        unlocked = @laplaya_task.get_visibility_status_for(current_student, current_school_class) != :locked
        render json: {unlocked: unlocked}
      end
    end
  end

  #POST /student_portal/assessment_tasks/:id
  #student_portal_assessment_task_response_path
  def assessment_response
    respond_to do |format|
      format.html do
        task_response = AssessmentTaskResponse.create(assessment_response_params)
        if task_response.errors.empty?
          redirect_to student_portal_activity_path(@assessment_task.activity_page)
        else
          bad_request_with_errors task_response
        end
      end
    end
  end

  #POST /student_portal/laplaya_tasks/:id
  #student_portal_laplaya_task_response_path
  def laplaya_task_response
    raise 'Route not implemented'
    # respond_to do |format|
    #   format.html do
    #     @laplaya_task_response.completed = true
    #     @laplaya_task_response.save
    #
    #     if @laplaya_task_response.errors.empty?
    #       redirect_to student_portal_activity_path(@laplaya_task.activity_page)
    #     else
    #       head :bad_request
    #     end
    #   end
    # end
  end

  #GET /student_portal/modules/:id/laplaya_sandbox
  def laplaya_sandbox
    respond_to do |format|
      format.html do
        sandboxmode = {}
        sandboxmode['modulePath_URL'] = student_portal_module_sandbox_files_path(@module_page)
        sandboxmode['baseFile_ID'] = @module_page.sandbox_base_laplaya_file.id
        @laplaya_ide_params[:sandboxMode] = sandboxmode
        laplaya_helper
      end
    end
  end

  #GET /student_portal/modules/:id/laplaya_sandbox
  def design_thinking_project
    respond_to do |format|
      format.html do
        @laplaya_ide_params[:fileID] = @project_laplaya_file.id
        laplaya_helper
      end
    end
  end

  #GET /student_portal/modules/:id/laplaya_sandbox/:file_id
  def laplaya_sandbox_file
    respond_to do |format|
      format.html do
        @laplaya_file = StudentResponse::SandboxResponseLaplayaFile.find(params[:file_id])
        unless current_school_class && current_school_class.module_pages.include?(@laplaya_file.module_page) &&
            @laplaya_file.owner == current_student
          raise CanCan::AccessDenied
        end
        sandboxmode = {}
        sandboxmode['modulePath_URL'] = student_portal_module_sandbox_files_path(@module_page)
        sandboxmode['baseFile_ID'] = @module_page.sandbox_base_laplaya_file.id
        @laplaya_ide_params[:fileID] = params[:file_id]
        @laplaya_ide_params[:sandboxMode] = sandboxmode
        laplaya_helper
      end
    end
  end

  private
  def load_project_laplaya_file
    @project_laplaya_file = ::StudentResponse::ProjectResponseLaplayaFile.find_by(
        owner: current_student,
        module_page: @module_page
    )
    if @project_laplaya_file.nil?
      @project_laplaya_file ||= ::StudentResponse::ProjectResponseLaplayaFile.create(
          owner: current_student,
          module_page: @module_page).clone(@module_page.project_base_laplaya_file)
      @project_laplaya_file.owner = current_user
      @project_laplaya_file.save!
    end
  end

  def load_variables
    action = params[:action].to_sym
    case action
      when :module_page
        @module_page = ModulePage.find(params[:id])
      when :laplaya_sandbox, :laplaya_sandbox_file
        @module_page = ModulePage.find(params[:id])
      when :design_thinking_project
        @module_page = ModulePage.find(params[:id])
        load_project_laplaya_file
      when :activity_page
        @activity_page = ActivityPage.find(params[:id])
        @module_page = @activity_page.module_page
      when :offline_task
        @offline_task = OfflineTask.find(params[:id])
        @activity_page = @offline_task.activity_page
        @module_page = @activity_page.module_page
      when :assessment_task, :assessment_response
        @assessment_task = AssessmentTask.find(params[:id])
        @activity_page = @assessment_task.activity_page
        @module_page = @activity_page.module_page
      when :laplaya_task, :laplaya_task_response
        @laplaya_task = LaplayaTask.find(params[:id])
        @activity_page = @laplaya_task.activity_page
        @module_page = @activity_page.module_page
        @laplaya_task_response = @laplaya_task.demo? || LaplayaTaskResponse.find_by(
            student: current_student,
            school_class: current_school_class,
            task: @laplaya_task
        )
      else
    end
  end

  def build_laplaya_task_response
    @laplaya_task_response ||= LaplayaTaskResponse.new_response(
        current_student,
        current_school_class,
        @laplaya_task
    )
  end

  def verify_valid_module
    unless @module_page.is_accessible?(current_student, current_school_class)
      redirect_to_first_module_page
    end
  end

  def verify_valid_activity
    unless @activity_page.is_accessible?(current_student, current_school_class)
      redirect_to_first_module_page
    end
  end

  def verify_valid_task
    task = @assessment_task || @laplaya_task || @offline_task
    unless task.is_accessible?(current_student, current_school_class)
      redirect_to_first_module_page
    end
  end

  def assessment_response_params
    result = params.require(:assessment_task_response).permit(:'assessment_question_responses_attributes' => [:selected, :assessment_question_id])
    result[:task_id] = @assessment_task.id
    result[:student_id] = current_student.id
    result[:school_class_id] = current_school_class.id
    result
  end

  def set_module_cookie
    if @module_page != nil
      cookies.permanent.signed[:student_last_module] = @module_page.id
    end
  end

  def redirect_to_first_module_page
    respond_to do |format|
      format.html do
        redirect_module = current_school_class.module_pages.student_visible.first
        if redirect_module
          flash[:warning]='You do not have permission to visit that page.'
          redirect_to student_portal_module_path(redirect_module)
        else
          flash[:alert]='There are no modules for that class.'
          redirect_to student_portal_root_path
        end
      end
      format.js do
        render text: 'You tried to access an inaccessible page', status: :bad_request
      end
    end
  end

  def json_request?
    request.format.json?
  end

end