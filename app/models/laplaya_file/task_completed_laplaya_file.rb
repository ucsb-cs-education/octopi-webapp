class TaskCompletedLaplayaFile < BaseLaplayaFile
  belongs_to :laplaya_task, foreign_key: :parent_id
  alias_attribute :parent, :laplaya_task
  validates :parent_id, uniqueness: true, allow_nil: false

end