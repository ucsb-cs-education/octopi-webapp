module Versionate
  def save_current_version
    PaperTrail.enabled = true
    PaperTrail.enabled_for_controller = true
    result = update_attribute(:updated_at, Time.now)
    PaperTrail.enabled_for_controller = false
    PaperTrail.enabled = false
    if result
      versions.last
    else
      false
    end
  end

  def save_children_versions
    date_created = versions.last.created_at
    if self.is_a? AssessmentTask
      for question in assessment_questions
        question.save_current_version.update_attribute(:created_at, date_created)
      end
    elsif self.is_a? ModulePage
      project_base_laplaya_file.save_current_version.update_attribute(:created_at, date_created)
      sandbox_base_laplaya_file.save_current_version.update_attribute(:created_at, date_created)
    elsif self.is_a? LaplayaTask
      task_base_laplaya_file.save_current_version.update_attribute(:created_at, date_created)
      task_completed_laplaya_file.save_current_version.update_attribute(:created_at, date_created)
      laplaya_analysis_file.save_current_version.update_attribute(:created_at, date_created)
    end
  end

  def restore_children(version)
    if  self.is_a? AssessmentTask
      date_created = versions.find(version.to_i).created_at
      for question in assessment_questions
        for question_version in question.versions
          if question_version.created_at == date_created
            question = question_version.reify
            question.save!
          end
        end
      end
    elsif self.is_a? LaplayaTask
      date_created = versions.find(version.to_i).created_at
      for laplaya_version in task_base_laplaya_file.versions
        if laplaya_version.created_at == date_created
          task_base_laplaya_file = laplaya_version.reify
          task_base_laplaya_file.save!
        end
      end
      for laplaya_version in task_completed_laplaya_file.versions
        if laplaya_version.created_at == date_created
          task_completed_laplaya_file = laplaya_version.reify
          task_completed_laplaya_file.save!
        end
      end
      for laplaya_version in laplaya_analysis_file.versions
        if laplaya_version.created_at == date_created
          laplaya_analysis_file = laplaya_version.reify
          laplaya_analysis_file.save!
        end
      end
    elsif self.is_a? ModulePage
      date_created = versions.find(version.to_i).created_at
      for laplaya_version in project_base_laplaya_file.versions
        if laplaya_version.created_at == date_created
          project_base_laplaya_file = laplaya_version.reify
          project_base_laplaya_file.save!
        end
      end
      for laplaya_version in sandbox_base_laplaya_file.versions
        if laplaya_version.created_at == date_created
          sandbox_base_laplaya_file = laplaya_version.reify
          sandbox_base_laplaya_file.save!
        end
      end
    end
  end

end