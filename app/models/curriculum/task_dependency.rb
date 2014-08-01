class TaskDependency < ActiveRecord::Base
  belongs_to :prerequisite, class_name: 'Task'
  belongs_to :dependant, class_name: 'Task'
  validates :prerequisite_id, presence: true
  validates :dependant_id, presence: true
  validate :within_same_module

  def within_same_module
    errors.add(:tasks, 'must be in the same module.') unless prerequisite.activity_page.module_page == dependant.activity_page.module_page
  end
end