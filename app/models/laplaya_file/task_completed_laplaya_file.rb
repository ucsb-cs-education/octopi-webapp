class TaskCompletedLaplayaFile < BaseLaplayaFile
  belongs_to :laplaya_task, foreign_key: :parent_id
  alias_attribute :parent, :laplaya_task
  validates :parent_id, uniqueness: true, allow_nil: false
  after_save :update_parent_updated_time

  private
  def update_parent_updated_time
    parent.update_attributes!(updated_at: updated_at)
  end
end