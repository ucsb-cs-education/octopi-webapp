class TaskResponse < ActiveRecord::Base
  belongs_to :school_class
  belongs_to :student
  belongs_to :task
  has_many :task_response_feedbacks, dependent: :destroy
  before_save :unlock_dependencies, :set_task_version
  validate :task_is_unlocked
  validates_presence_of :task
  scope :completed, -> { where(completed: true) }

  def task_is_unlocked
    errors.add(:taskresponse, 'must be unlocked') unless unlock
  end


  def unlock_dependencies(force = false)
    if (self.completed_changed? && self.completed == true) || force
      unlock.update_attribute(:hidden, true) if task.is_a?(AssessmentTask)
      task.activity_dependants.each do |activity|
        if check_prereqs(activity) && activity.find_unlock_for(student, school_class).nil?
          Unlock.create(student: student, school_class: school_class, unlockable: activity)
        end
      end
      task.dependants.each do |depdendant_task|
        if check_prereqs(depdendant_task) && depdendant_task.find_unlock_for(student, school_class).nil?
          Unlock.create(student: student, school_class: school_class, unlockable: depdendant_task)
        end
      end
    end
  end

  def unlock
    Unlock.find_for(student, school_class, task)
  end

  def check_prereqs(model)
    model.prerequisites.each { |y|
      unless y==self.task
        prereq_response = TaskResponse.find_by(student: student, school_class: school_class, task: y)

        if prereq_response.nil? || !prereq_response.completed
          return false
        end
      end
    }
    true
  end

  private
  def set_task_version
    unless task.versions.last &&
        %w(manual_version auto_task_version).include?(task.versions.last.event) &&
        task.versions.last.created_at == task.updated_at
      task.save_current_version(paper_trail_event: 'auto_task_version')
    end
    assign_attributes(version_date: task.updated_at)
  end
end