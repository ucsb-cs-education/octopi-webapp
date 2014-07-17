class StudentPortal::PagesController < StudentPortal::BaseController
  before_action :signed_in_student
  before_action :load_variables
  before_action :verify_valid_module_page, only: [:module_page, :activity]
  before_action :verify_valid_page_task, only: [:laplaya_task, :assessment_task]
  before_action :verify_unlocked_activity, only: [:activity]
  after_action :set_module_cookie, only: [:module_page]

  #GET /student_portal/modules/:id
  #student_portal_module_path
  def module_page
    @unlocks = Unlock.find_for(current_student, current_school_class, @module_page.activity_pages)
  end

  #GET /student_portal/activities/:id
  #student_portal_activity_path
  def activity_page
    @unlocks = Unlock.find_for(current_student, current_school_class, @activity_page.tasks)
  end

  #GET /student_portal/assessment_tasks/:id
  #student_portal_assessment_task_path
  def assessment_task
    @task_response = AssessmentTaskResponse.new(
        student: current_student,
        school_class: current_school_class,
        task: @assessment_task)
    @assessment_task.children.each do |x|
      @task_response.assessment_question_responses.build(assessment_question: x)
    end
  end

  #GET /student_portal/laplaya_tasks/:id
  #student_portal_laplaya_task_path
  def laplaya_task
    @task_response = LaplayaTaskResponse.new(
        student: current_student,
        school_class: current_school_class,
        task: @laplaya_task)
  end

  #POST /student_portal/assessment_tasks/:id
  #student_portal_assessment_task_response_path
  def assessment_response
    task_response = AssessmentTaskResponse.create(assessment_response_params)
    if task_response.errors.empty?
      redirect_to student_portal_activity_path(@assessment_task.parent)
    else
      head :bad_request
    end
  end

  #POST /student_portal/laplaya_tasks/:id
  #student_portal_laplaya_task_response_path
  def laplaya_task_response
    @laplaya_task = LaplayaTask.find(params[:id])
    task_response = LaplayaTaskResponse.create(
        task_id: @task.id,
        student_id: current_student.id,
        school_class_id: current_school_class.id,
        completed: true)

    if task_response.errors.empty?
      redirect_to student_portal_activity_path(@laplaya_task.parent)
    else
      head :bad_request
    end
  end

  private
  def load_variables
    if params[:action] == :module_page
      @module_page = ModulePage.find(params[:id])
    elsif params[:action] == :activity_page
      @activity_page = ActivityPage.find(params[:id])
      @module_page = @activity_page.module_page
    elsif params[:action] == :assessment_task || params[:action] == :assessment_response
      @assessment_task = AssessmentTask.find(params[:id])
      @activity_page = @assessment_task.activity_page
      @module_page = @activity_page.module_page
    elsif params[:action] == :laplaya_task || params[:action] == :laplaya_task_response
      @laplaya_task = LaplayaTask.find(params[:id])
      @activity_page = @laplaya_task.activity_page
      @module_page = @activity_page.module_page
    end
  end

  def assessment_response_params
    result = params.require(:assessment_task_response).permit(:'assessment_question_responses_attributes' => [:selected, :assessment_question_id])
    result[:task_id] = @assessment_task.id
    result[:student_id] = current_student.id
    result[:school_class_id] = current_school_class.id
    result
  end

  def find_unlocks_for(unlockable)
    Unlock.find_for(current_student, current_school_class, unlockable)
  end

  def set_module_cookie
    if @module_page != nil
      cookies.permanent.signed[:student_last_module] = @module_page.id
    end
  end

  def load_valid_module_page
    redirect_to_first_module_page unless in_a_valid_module_page?
  end

  def verify_unlocked_activity
    unless find_unlocks_for @activity_page
      redirect_to_first_module_page
    end
  end

  def verify_valid_page_task
    task = @assessment_task || @laplaya_task
    if in_a_valid_module_page?
      task_unlock = find_unlocks_for(task)
      activity_unlock = find_unlocks_for(task.activity_page)
      unless task_unlock && activity_unlock && !task_unlock.hidden
        redirect_to_first_module_page
      end
    else
      redirect_to_first_module_page
    end
  end

  def in_a_valid_module_page?
    current_school_class.module_pages.include?(@module_page)
  end

  def redirect_to_first_module_page
    redirect_module = current_school_class.module_pages.first
    if redirect_module
      flash[:warning]='You do not have permission to visit that page.'
      redirect_to student_portal_module_path(redirect_module)
    else
      flash[:alert]='There are no modules for that class.'
      redirect_to student_portal_root_path
    end
  end
end