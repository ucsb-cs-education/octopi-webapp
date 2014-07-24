class LaplayaTask < Task
  has_one :task_base_laplaya_file, foreign_key: :parent_id
  has_one :laplaya_analysis_file, foreign_key: :task_id
  alias_attribute :children, :task_base_laplaya_file
  validates :title, presence: true

  def is_accessible?(student, school_class)
    status = get_visibility_status_for(student, school_class)
    status == :visible || status == :completed
  end

  def get_visibility_status_for(student, school_class)
    if find_unlock_for(student, school_class).nil?
      :locked
    else
      response = TaskResponse.find_by(student: student, school_class: school_class, task: self)
      result = :visible
      if response.present? && response.completed
        result = :completed
      end
      result
    end
  end
end