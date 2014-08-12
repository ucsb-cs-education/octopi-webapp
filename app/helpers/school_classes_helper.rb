#we need this here so that when classes are dynamically loaded in development, we see all the students
require 'test_student'
module SchoolClassesHelper

  def ordered_students
    @students ||= @school_class.students
    @students = @students.order(first_name: :asc, last_name: :asc)
    @students = @students.where(%Q["users"."type" = 'Student'] +
                                    ((teacher_using_test_student?) ? %Q[or "users"."id" = '#{current_staff.test_student.id}'] : ''))

  end

  def average_task_completion
    @responses.count/(@tasks.count * @school_class.students.count).to_f
  end

  def average_task_unlock
    @unlocks.count/(@tasks.count * @school_class.students.count).to_f
  end

  def get_path_for_task(task)
    if task
      case task[:type]
        when 'AssessmentTask'
          assessment_task_path(task[:id])
        when 'LaplayaTask'
          laplaya_task_path(task[:id])
        when 'OfflineTask'
          offline_task_path(task[:id])
        else
          nil
      end
    else
      nil
    end
  end

end
