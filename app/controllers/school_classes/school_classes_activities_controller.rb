class SchoolClasses::SchoolClassesActivitiesController < SchoolClassesController
  load_and_authorize_resource :school_class

  def activity_page
    @activity_page = ActivityPage.includes(tasks: [:unlocks]).find(params[:id])
    #TODO: preload all task visibililties so that they do not need to be found when loading the page?
    @activity_unlocks = Unlock.where(student: @school_class.students, school_class: @school_class, unlockable: @activity_page)
    @students = @school_class.students.order(:last_name).order(:first_name).includes(:task_responses)
    @graph_info = @school_class.activity_progress_graph_array_for(@activity_page)
  end

end

