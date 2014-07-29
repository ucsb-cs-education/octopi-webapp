class SchoolClasses::SchoolClassesStudentProgressController < SchoolClassesController
  load_and_authorize_resource :school_class

  def student_progress
    @student = Student.find(params[:id])
    @module_pages = @school_class.module_pages.includes(:activity_pages)
    #@module_pages = @school_class.module_pages.includes(activity_pages: [:tasks])
    @unlocks = Unlock.where(student: @student, school_class: @school_class)

    #done to get a count of all tasks in the modules in the class
    @tasks = Task.where(activity_page: (ActivityPage.where(module_page: @module_pages)))
    #TODO: load all visibility statuses for tasks here?

    @responses = TaskResponse.where(student: @student, school_class: @school_class)
    @graph_info = @school_class.student_progress_graph_array_for(@student)
  end

end

