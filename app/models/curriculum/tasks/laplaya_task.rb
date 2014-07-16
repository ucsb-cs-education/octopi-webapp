class LaplayaTask < Task
  has_one :task_base_laplaya_file, foreign_key: :parent_id, dependent: :destroy
  has_one :task_completed_laplaya_file, foreign_key: :parent_id, dependent: :destroy
  has_one :laplaya_analysis_file, foreign_key: :task_id, dependent: :destroy
  alias_attribute :children, :task_base_laplaya_file

  def is_accessible?(student, school_class)
    status = get_visibility_status_for(student, school_class)
    status == :visible || status == :completed
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

end