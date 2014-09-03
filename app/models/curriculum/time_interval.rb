class TimeInterval < ActiveRecord::Base
  belongs_to :task_response
  validate :ends_after_begins
  validates :begin_time, presence: true
  scope :order_by_newest, -> { order('created_at') }

  def ends_after_begins
    errors.add(:timeinterval, 'cannot have an end time earlier than a begin time') unless (end_time.nil? || (end_time >= begin_time))
  end

  def length
    (begin_time.nil? || end_time.nil?) ? 0 : end_time - begin_time
  end

  def complete
    begin
      json_array = JSON.parse(task_response.time_intervals)
    rescue Exception => e
      #deal with an incorrectly formatted json
      json_array = []
    end
    json_array.push({begin_time: begin_time, end_time: end_time})
    task_response.update(time_intervals: JSON.generate(json_array))
    self.destroy!
  end
end