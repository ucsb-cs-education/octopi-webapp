class LaplayaTask < Task
  has_one :task_base_laplaya_file, foreign_key: :parent_id, dependent: :destroy
  has_one :task_completed_laplaya_file, foreign_key: :parent_id, dependent: :destroy
  has_one :laplaya_analysis_file, foreign_key: :task_id, dependent: :destroy
  alias_attribute :children, :task_base_laplaya_file

  def is_accessible?(student, school_class)
    if visible_to_students
      status = get_visibility_status_for(student, school_class)
      status == :visible || status == :completed
    end
  end

  def get_visibility_status_for(student, school_class)
    LaplayaTask.get_visibility_status(
        find_unlock_for(student, school_class),
        TaskResponse.find_by(student: student, school_class: school_class, task: self))
  end

  def self.get_visibility_status(unlock, response)
    if unlock.nil?
      :locked
    else
      result = :visible
      if response.present? && response.completed
        result = :completed
      end
      result
    end
  end


  def save_children_versions!(paper_trail_event, recursive)
    child_versions = []
    [
        [task_base_laplaya_file, :task_base_laplaya_file],
        [task_completed_laplaya_file, :task_completed_laplaya_file],
        [laplaya_analysis_file, :laplaya_analysis_file]
    ].each do |child|
      child_versions.append(
          {
              type: child[1],
              version_id: (child[0].save_current_version_helper!(paper_trail_event, recursive)).id
          })
    end
    child_versions.to_json
  end

  def restore_children_helper!(child_versions, duplicate)
    base_version = child_versions.select { |x| x[:type] == 'task_base_laplaya_file' }.first
    completed_version = child_versions.select { |x| x[:type] == 'task_completed_laplaya_file' }.first
    analysis_version = child_versions.select { |x| x[:type] == 'laplaya_analysis_file' }.first
    base_version = PaperTrail::Version.find_by(
        item_type: 'LaplayaFile', id: base_version[:version_id])
    completed_version = PaperTrail::Version.find_by(
        item_type: 'LaplayaFile', id: completed_version[:version_id])
    analysis_version = PaperTrail::Version.find_by(
        item_type: 'LaplayaAnalysisFile', id: analysis_version[:version_id])
    unless base_version && completed_version && analysis_version
      raise ActiveRecord::Rollback.new 'Number of child versions found does not match number saved!'
    end
    override_parent = (duplicate) ? self : nil
    unless duplicate
      if base_version.item_id != task_base_laplaya_file.id
        task_base_laplaya_file.destroy!
      end

      if completed_version.item_id != task_completed_laplaya_file.id
        task_completed_laplaya_file.destroy!
      end

      if analysis_version.item_id != laplaya_analysis_file.id
        laplaya_analysis_file.destroy!
      end
    end

    self.class.restore_version_helper(base_version, duplicate, override_parent)
    self.class.restore_version_helper(completed_version, duplicate, override_parent)
    self.class.restore_version_helper(analysis_version, duplicate, override_parent)
  end
end