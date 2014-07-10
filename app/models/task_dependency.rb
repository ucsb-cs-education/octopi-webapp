class TaskDependency < ActiveRecord::Base
  belongs_to :prerequisite, class_name: 'Task'
  belongs_to :dependant, class_name: 'Task'
  validates :prerequisite_id, presence: true
  validates :dependant_id, presence: true
end