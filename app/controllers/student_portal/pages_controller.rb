class StudentPortal::PagesController < StudentPortal::BaseController

  def module
    @page = ModulePage.find(params[:id])
    set_module_cookie
  end

  def activity
    @page = ActivityPage.find(params[:id])
  end

  def assessment_task
    @page = AssessmentTask.find(params[:id])
  end

  def set_module_cookie
    if @page != nil
      cookies.permanent.signed[:student_last_module] = @page.id
    end
  end
end