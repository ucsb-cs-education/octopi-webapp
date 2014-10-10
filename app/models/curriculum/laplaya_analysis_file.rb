class LaplayaAnalysisFile < ActiveRecord::Base
  belongs_to :laplaya_task, foreign_key: :task_id
  alias_attribute :parent, :laplaya_task
  has_paper_trail :on=> [:update, :destroy]
  include Versionate
  after_save :update_parent_updated_time

  private
  def update_parent_updated_time
    parent.update_attributes!(updated_at: updated_at)
  end
end
