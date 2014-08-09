module SchoolClassesHelper

  def average_task_completion
    @responses.count/(@tasks.count * @school_class.students.count).to_f
  end

  def average_task_unlock
    @unlocks.count/( @tasks.count * @school_class.students.count).to_f
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
