class TaskBaseLaplayaFile < BaseLaplayaFile
  belongs_to :laplaya_task, foreign_key: :parent_id
  alias_attribute :parent, :laplaya_task
  validates :parent_id, uniqueness: true, allow_nil: false

  def self.new_base_file(laplaya_task)
    return self.create!(file_name: 'New Project', laplaya_task: laplaya_task)
  end

end