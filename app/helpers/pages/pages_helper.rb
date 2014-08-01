module Pages::PagesHelper

  def teacher_view?
    false
  end

  def get_time(object)
    t = object.updated_at.in_time_zone('Pacific Time (US & Canada)')
    t.strftime("#{t.day.ordinalize} %B, %Y %I:%M %p")
  end

  def get_path_for_task(task)
    case task.class.to_s
      when 'AssessmentTask'
        student_portal_assessment_task_path(task)
      when 'LaplayaTask'
        student_portal_laplaya_task_path(task)
      when 'OfflineTask'
        student_portal_offline_task_path(task)
      else
        nil
    end
  end
end
