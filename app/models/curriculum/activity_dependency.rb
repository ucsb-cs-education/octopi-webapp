class ActivityDependency < ActiveRecord::Base
  belongs_to :task_prerequisite, class_name: 'Task'
  belongs_to :activity_dependant, class_name: 'ActivityPage'
  validates :task_prerequisite_id, presence: true
  validates :activity_dependant_id, presence: true
  alias_attribute :dependant, :activity_dependant
  validate :within_same_module
  validate :cannot_depend_on_child_task

  def within_same_module
    errors.add(:task_and_activity,"must be in the same module.") unless task_prerequisite.activity_page.module_page == activity_dependant.module_page
  end

  def cannot_depend_on_child_task
    errors.add(:activity,"cannot depend on a task within itself") if task_prerequisite.in?(activity_dependant.children)
  end
end