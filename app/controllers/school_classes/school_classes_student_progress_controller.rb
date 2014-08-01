class SchoolClasses::SchoolClassesStudentProgressController < SchoolClassesController
  load_and_authorize_resource :school_class

  def student_progress
    @student = Student.find(params[:id])
    @module_pages = @school_class.module_pages.includes(activity_pages: [:tasks])
    @unlocks = Unlock.where(student: @student, school_class: @school_class)
    @info = @module_pages.map { |module_page| {title: module_page.title, id: module_page.id, activity_pages: module_page.activity_pages.map {
        |activity| {title: activity.title, id: activity.id, unlocked: @unlocks.find_by(student: @student, unlockable: activity).nil? ? false : true,
                    tasks: activity.tasks.map {
                        |task| {title: task.title, id: task.id, visibility: task.get_visibility_status_for(@student, @school_class)}
                    }}
    }}
    }

    @graph_info = @school_class.student_progress_graph_array_for(@student)
  end

end

