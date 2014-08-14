class SchoolClasses::SchoolClassesStudentProgressController < SchoolClassesController
  load_and_authorize_resource :school_class

  def student_progress
    @student = Student.find(params[:id])
    @module_pages = @school_class.module_pages.student_visible.includes(activity_pages: [:tasks])
    @activity_unlocks = ActivityUnlock.where(student: @student, school_class: @school_class).select(:unlocked)
    @info = @module_pages.map { |module_page| {title: module_page.title, id: module_page.id, activity_pages: module_page.activity_pages.student_visible.map {
        |activity| {title: activity.title, id: activity.id, unlocked: @activity_unlocks.find_by(student: @student, activity_page: activity, unlocked: true).nil? ? false : true,
                    tasks: activity.tasks.student_visible.map {
                        |task| {title: task.title, id: task.id, visibility: task.get_visibility_status_for(@student, @school_class)}
                    }}
    }}
    }

    @graph_info = @school_class.student_progress_graph_array_for(@student)
  end

  def reset_dependency_graph
    @student = Student.find(params[:student_progress][:student_id])
    @student.reset_dependency_graph_for(@school_class)
    redirect_to(:back)
  end

end

