module StudentPortal::PagesHelper

  def current_class_modules_for_select
    current_school_class.module_pages.order(parent_id: :asc, position: asc)
  end

  def get_path_for_task(task)
    if task
      case task.type
        when 'AssessmentTask'
          student_portal_assessment_task_path(task)
        when 'LaplayaTask'
          student_portal_laplaya_task_path(task)
        when 'OfflineTask'
          student_portal_offline_task_path(task)
        else
          nil
      end
    else
      nil
    end
  end
end