class ActivityDependency < ActiveRecord::Base
  belongs_to :task_prerequisite, class_name: 'Task'
  belongs_to :activity_dependant, class_name: 'ActivityPage'
  validates :task_prerequisite_id, presence: true
  validates :activity_dependant_id, presence: true
end