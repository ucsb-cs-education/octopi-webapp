class SchoolClassesActivitiesController < SchoolClassesController
  load_and_authorize_resource :school_class

  def activity_page
    @activity_page = ActivityPage.find(params[:id])
    @tasks= @activity_page.tasks
    @unlocks = Unlock.where(student: @school_class.students, school_class: @school_class)
    @responses = TaskResponse.where(student: @school_class.students, school_class: @school_class)
    @students = @school_class.students.order(:last_name)
  end

end