module LaplayaModule
  extend ActiveSupport::Concern

  def laplaya_helper
    render 'laplaya', layout: false
  end

  def set_developer_mode
    if staff_signed_in? && Ability.new(current_staff).can?(:see_developer_view, LaplayaFile)
      @laplaya_ide_params['developerMode'] = true
    end
  end

  #Should be called before all laplaya based actions
  def setup_laplaya
    js false
    @laplaya_ide_params = {}
    @laplaya_ide_params['root_path'] = Rails.application.config.laplaya_root_path
  end

  #Should be used whenever we are loading a specific file
  def force_no_trailing_slash
    force_slash :noslash
  end

  #Should be used whenever we are loading an empty sandbox
  def force_trailing_slash
    force_slash :slash
  end

  def force_slash(slash = :slash)
    if slash == :slash
      redirect_to request.original_url + '/' unless request.original_url.match(/\/$/)
    elsif slash == :noslash
      redirect_to request.original_url.gsub /\/+$/, '' unless request.original_url.match(/[^\/]$/)
    end
  end

  def get_path_for_task(task, options = {})
    if task
      if options[:developer] && options[:developer] == true
        case task.type
          when 'AssessmentTask'
            assessment_task_path(task)
          when 'LaplayaTask'
            laplaya_task_path(task)
          when 'OfflineTask'
            offline_task_path(task)
          else
            nil
        end
      else
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
      end
    end
  end

end