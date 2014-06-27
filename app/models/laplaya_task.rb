class LaplayaTask < Task
  has_one :task_base_laplaya_file, foreign_key: :task_id
  alias_attribute :children, :task_base_laplaya_file
end