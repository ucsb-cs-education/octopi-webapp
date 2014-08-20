class SchoolClasses::SchoolClassesActivitiesController < SchoolClassesController
  load_and_authorize_resource :school_class
  include SchoolClassesHelper

  def activity_page
    @activity_page = ActivityPage.includes(:tasks).find(params[:id])
    authorize! :show, @activity_page
    @students = @school_class.students.includes(:task_responses).select('id,first_name,last_name')
    @students = ordered_students
    @activity_unlocks = Unlock.where(student: @students.ids, school_class: @school_class, unlockable: @activity_page)

    @info = {:activity => {title: @activity_page.title, id: @activity_page.id, students_who_unlocked: @activity_unlocks.pluck(:student_id)},
             :tasks => @activity_page.tasks.student_visible.map { |task|
               {id: task.id, title: task.title, type: task.type,
                statuses: @students.map { |student|
                  {student.id => task.get_visibility_status_for(student, @school_class)}
                }.reduce({}, :merge)} },
             :students => @students.map { |student|
               {student.id => {id: student.id, name: student.name, first_name: student.first_name, last_name: student.last_name,
                               #Must pluck id's from the task due to a bug
                               #https://github.com/rails/rails/issues/15920
                               percent_done: (student.task_responses.where(task: @activity_page.tasks.student_visible.all.pluck(:id)).where(completed: true).count.to_f/@activity_page.tasks.student_visible.count)}}
             }.reduce({}, :merge),
             :counts => {unlocked_count: @activity_unlocks.count, student_count: @students.count(:id)}
    }

    @graph_info = @school_class.activity_progress_graph_array_for(@activity_page, current_student)
  end

  def reset_page
    @activity_page = ActivityPage.includes(:tasks).find(params[:id])
    authorize! :show, @activity_page
    @activity_unlocks = Unlock.where(student: @school_class.students, school_class: @school_class, unlockable: @activity_page)
    @students = @school_class.students.includes(:task_responses).select('id,first_name,last_name')
    @students = ordered_students

    @info = {:activity => {title: @activity_page.title, id: @activity_page.id, students_who_unlocked: @activity_unlocks.pluck(:student_id)},
             :tasks => @activity_page.tasks.student_visible.map { |task|
               {id: task.id, title: task.title, type: task.type,
                responses: @students.map { |student|
                  #in the removed unlocks branch, change this to also check if it is exists or if it has children
                  {student.id => student.task_responses.find_by(task: task, school_class: @school_class)}
                }.reduce({}, :merge)} },
             :students => @students.map { |student|
               {student.id => {id: student.id, name: student.name, first_name: student.first_name, last_name: student.last_name}}
             }.reduce({}, :merge)
    }
  end
end

