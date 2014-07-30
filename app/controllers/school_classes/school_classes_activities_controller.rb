class SchoolClasses::SchoolClassesActivitiesController < SchoolClassesController
  load_and_authorize_resource :school_class

  def activity_page
    @activity_page = ActivityPage.includes(tasks: [:unlocks]).find(params[:id])
    @activity_unlocks = Unlock.where(student: @school_class.students, school_class: @school_class, unlockable: @activity_page)
    @students = @school_class.students.order(:last_name).order(:first_name).includes(:task_responses)

    @info = {:activity => {title: @activity_page.title, id: @activity_page.id, students_who_unlocked: @activity_unlocks.map { |unlock|
      {unlock.student_id => :unlocked}
    }.reduce({}, :merge)},
             :tasks => @activity_page.tasks.map { |task|
               {id: task.id, title: task.title, statuses: @students.map { |student|
                 {student.id => task.get_visibility_status_for(student, @school_class)}
               }.reduce({}, :merge)} },
             :students => @students.map { |student|
               {student.id => {id: student.id, name: student.name,
                               percent_done: (student.task_responses.where(completed: true).count.to_f/@activity_page.tasks.count)}}
             }.reduce({}, :merge),
             :counts => {unlocked_count: @activity_unlocks.count, student_count: @students.count}
    }
    @graph_info = @school_class.activity_progress_graph_array_for(@activity_page)
  end

end


#@info[:students].map{|x| @info[:activity][:students_who_unlocked][x[1][:id]]}
