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

  def getShowColors
    max = @graph_info.count()
    (0...max).map { |i|
      r = Math.cos((6.28/max)*i)* 127+128
      g = Math.cos((6.28/max)*i + 3.14/2) * 127+128
      b = Math.cos((6.28/max)*i + 3.14) * 127+128

      "rgb(#{r.to_i},#{g.to_i},#{b.to_i})"
    }
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
