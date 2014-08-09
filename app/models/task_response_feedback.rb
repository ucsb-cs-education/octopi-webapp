class TaskResponseFeedback < ActiveRecord::Base
  belongs_to :task_response
  belongs_to :task
  before_save :set_task_id
  validates_presence_of :task_response


  private
  def set_task_id
    if task_id_changed? || task_response_id_changed?
      self.task = task_response.task
    end
  end

end