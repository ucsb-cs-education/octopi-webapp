class SchoolClasses::SchoolClassesStudentProgressController < SchoolClassesController
  load_and_authorize_resource :school_class

  def student_progress
    @student = Student.find(params[:id])
    @module_pages = @school_class.module_pages.student_visible.includes(activity_pages: [:tasks])
    @unlocks = Unlock.where(student: @student, school_class: @school_class)
    @info = @module_pages.map { |module_page| {title: module_page.title, id: module_page.id, activity_pages: module_page.activity_pages.student_visible.map {
        |activity| {title: activity.title, id: activity.id, unlocked: @unlocks.find_by(student: @student, unlockable: activity).nil? ? false : true,
                    tasks: activity.tasks.student_visible.map {
                        |task| student_response = @student.task_responses.find_by(task: task)
                      {title: task.title,
                       id: task.id,
                       visibility: task.get_visibility_status_for(@student, @school_class),
                       response_id: (student_response.nil? ? nil : student_response.id)}
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

