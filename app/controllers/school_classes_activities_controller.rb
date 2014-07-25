class SchoolClassesActivitiesController < SchoolClassesController
  load_and_authorize_resource :school_class

  def activity_page
    #this is not very fast! How to speed up?

    @activity_page = ActivityPage.find(params[:id])
    @tasks= @activity_page.tasks
    #TODO: preload all task visibililties so that they do not need to be found when loading the page?
    @activity_unlocks = Unlock.where(student: @school_class.students, school_class: @school_class, unlockable: @activity_page)
    # BUG: https://github.com/rails/rails/issues/15920
    # Have to pluck unlockables until fixed
    @task_unlocks = Unlock.where(student: @school_class.students, school_class: @school_class, unlockable_type: "Task", unlockable_id: @tasks.pluck(:id))
    @responses = TaskResponse.where(student: @school_class.students, school_class: @school_class)
    @students = @school_class.students.order(:last_name).order(:first_name)

  end

end

