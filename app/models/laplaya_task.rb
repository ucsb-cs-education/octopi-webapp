class LaplayaTask < Task
  has_one :task_base_laplaya_file, foreign_key: :parent_id
  alias_attribute :children, :task_base_laplaya_file
  validates :title, presence: true

  def get_visibility_status_for(student, school_class)
    if find_unlock_for(student, school_class).nil?
      :locked
    else
      response = TaskResponse.find_by(student: student, school_class: school_class, task: self)
      response.nil? || (response.completed) ? :completed : true
    end
  end
end