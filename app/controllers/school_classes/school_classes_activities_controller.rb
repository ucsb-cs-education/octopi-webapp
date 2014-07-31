class SchoolClasses::SchoolClassesActivitiesController < SchoolClassesController
  load_and_authorize_resource :school_class

  def activity_page
    @activity_page = ActivityPage.includes(tasks: [:unlocks]).find(params[:id])
    @activity_unlocks = Unlock.where(student: @school_class.students, school_class: @school_class, unlockable: @activity_page)
    @students = @school_class.students.includes(:task_responses)

    @info = {:activity => {title: @activity_page.title, id: @activity_page.id, students_who_unlocked: @activity_unlocks.map { |unlock|
      {unlock.student_id => :unlocked}
    }.reduce({}, :merge)},
             :tasks => @activity_page.tasks.map { |task|
               {id: task.id, unique_title: (@activity_page.tasks.where(title: task.title).count>1 ?
                   task.title+"("+task.id.to_s+")" : task.title),
                title: task.title, type: (task.is_a?(AssessmentTask) ? "AssessmentTask" : "LaplayaTask"),
                statuses: @students.map { |student|
                  {student.id => task.get_visibility_status_for(student, @school_class)}
                }.reduce({}, :merge)} },
             :students => @students.map { |student|
               {student.id => {id: student.id, name: student.name,
                               #Must pluck id's from the task due to a bug
                               #https://github.com/rails/rails/issues/15920
                               percent_done: (student.task_responses.where(task: @activity_page.tasks.all.pluck(:id)).where(completed: true).count.to_f/@activity_page.tasks.count)}}
             }.reduce({}, :merge),
             :counts => {unlocked_count: @activity_unlocks.count, student_count: @students.count}
    }

    @graph_info = @school_class.activity_progress_graph_array_for(@activity_page)
  end


end

