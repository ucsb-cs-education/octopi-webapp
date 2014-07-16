class StudentPortal::PagesController < StudentPortal::BaseController
  before_action :signed_in_student
  before_action :verify_valid_module_page, only: [:module_page, :activity]
  before_action :verify_valid_page_task, only: [:laplaya_task, :assessment_task]
  before_action :verify_unlocked_activity, only: [:activity]


  def module_page
    @page = ModulePage.find(params[:id])
    activity_ids = @page.activity_pages.pluck(:id)
    @unlocks = Unlock.where(student: current_student.id, school_class: current_school_class.id, unlockable_type: "Page", unlockable_id: activity_ids)
    set_module_cookie
  end

  def activity
    @page = ActivityPage.find(params[:id])
    task_ids = @page.tasks.pluck(:id)
    @unlocks = Unlock.where(student_id: current_student.id, school_class_id: current_school_class.id, unlockable: @page.tasks)
  end

  def assessment_task
    @page = AssessmentTask.find(params[:id])
    @task_response = AssessmentTaskResponse.new(student_id: current_student.id, school_class_id: current_school_class.id, task_id: @page.id)
    @page.children.each do |x|
      @task_response.assessment_question_responses.build(assessment_question: x)
    end

  end

  def laplaya_task
    @page = LaplayaTask.find(params[:id])
    @task_response = LaplayaTaskResponse.new(student_id: current_student.id, school_class_id: current_school_class.id, task_id: @page.id)
  end


  def set_module_cookie
    if @page != nil
      cookies.permanent.signed[:student_last_module] = @page.id
    end
  end

  def verify_valid_module_page
    @page = Page.find(params[:id])
    @page = @page.module_page if @page.is_a?(ActivityPage)
    redirect_to_first_module_page unless in_a_valid_module_page?(@page)
  end

  def verify_unlocked_activity
    @page = ActivityPage.find(params[:id])
    unless Unlock.find_by(student: current_student,
                          school_class: current_school_class,
                          unlockable: @page)
      redirect_to_first_module_page
    end
  end

  def verify_valid_page_task
    @page = Task.find(params[:id])
    if !in_a_valid_module_page?(@page.activity_page.module_page)
      redirect_to_first_module_page
    else
      unlocker = find_unlocks_for(@page.becomes(Task))
      activity_unlocker = find_unlocks_for(@page.activity_page)
      if unlocker.nil?
        redirect_to_first_module_page
      elsif activity_unlocker.nil?
        redirect_to_first_module_page
      elsif unlocker.hidden==true && @page.is_a?(AssessmentTask)
        redirect_to_first_module_page
      end
    end
  end

  def in_a_valid_module_page?(which_module)
    return true if current_school_class.module_pages.include?(which_module)
    return false
  end

  def redirect_to_first_module_page
    id = current_school_class.module_pages.first.id unless current_school_class.module_pages.first==nil
    if id==nil
      flash[:alert]='There are no modules for that class.'
      redirect_to '/'
    else
      flash[:warning]='You do not have permission to visit that page.'
      redirect_to action: 'module_page', id: id
    end
  end

  def assessment_response
    @task = AssessmentTask.find(params[:id])
    task_response = AssessmentTaskResponse.create(assessment_response_params)

    if task_response.errors.empty?
      redirect_to student_portal_activity_path(@task.parent)
    else
      head :bad_request
    end
  end

  def laplaya_task_response
    @task = LaplayaTask.find(params[:id])
    task_response = LaplayaTaskResponse.create(task_id: @task.id, student_id: current_student.id, school_class_id: current_school_class.id, completed: true)

    if task_response.errors.empty?
      redirect_to student_portal_activity_path(@task.parent)
    else
      head :bad_request
    end
  end

  private
  def assessment_response_params
    result = params.require(:assessment_task_response).permit(:'assessment_question_responses_attributes' => [:selected, :assessment_question_id])
    result[:task_id] = @task.id
    result[:student_id] = current_student.id
    result[:school_class_id] = current_school_class.id
    result
  end

  def find_unlocks_for(unlockable)
    Unlock.find_by(student: current_student, school_class: current_school_class, unlockable: unlockable)
  end

end