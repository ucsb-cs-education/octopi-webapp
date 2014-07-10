class StudentPortal::PagesController < StudentPortal::BaseController
  before_action :signed_in_student
  before_action :verify_valid_module_page, only: [:module_page, :activity]
  before_action :verify_valid_module_page_task, only: [:assessment_task]
  before_action :verify_unlocked_activity, only: [:activity]

  def module_page
    @page = ModulePage.find(params[:id])
    activity_ids = @page.activity_pages.pluck(:id)
    @unlocks = Unlock.where(student_id: current_student.id, school_class_id: current_school_class.id, unlockable_type: "Page", unlockable_id: activity_ids)
    set_module_cookie
  end

  def activity
    @page = ActivityPage.find(params[:id])
    task_ids = @page.tasks.pluck(:id)
    @unlocks = Unlock.where(student_id: current_student.id, school_class_id: current_school_class.id, unlockable_type: "Task", unlockable_id: task_ids)
  end

  def assessment_task
    @page = AssessmentTask.find(params[:id])
  end



  def set_module_cookie
    if @page != nil
      cookies.permanent.signed[:student_last_module] = @page.id
    end
  end

  def verify_valid_module_page
    @page = Page.find(params[:id])
    @page = @page.parent if @page.is_a?(ActivityPage)
    redirect_to_first_module_page if !in_a_valid_module_page?(@page)
  end

  def verify_unlocked_activity
    @page = Page.find(params[:id])
    redirect_to_first_module_page if Unlock.find_by(student_id: current_student.id, school_class_id: current_school_class.id,
                                                    unlockable_type: "Page", unlockable_id:@page.id)==nil
  end

  def verify_valid_module_page_task
    @page = AssessmentTask.find(params[:id])
    if !in_a_valid_module_page?(@page.parent.parent)
      redirect_to_first_module_page
    else
      unlocker = Unlock.find_by(student_id: current_student.id, school_class_id: current_school_class.id,unlockable_type:"Task", unlockable_id:@page.id)
      redirect_to_first_module_page if unlocker == nil || unlocker.completed==true
    end
  end

  def in_a_valid_module_page?(which_module)
    current_school_class.module_pages.each {|x|
      return true if x.id == which_module.id
    }
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
end