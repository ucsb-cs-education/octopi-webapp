class TaskResponse < ActiveRecord::Base
  belongs_to :school_class
  belongs_to :student
  belongs_to :task
  before_save :unlock_dependencies
  validate :task_is_unlocked

  def task_is_unlocked
    errors.add(:taskresponse, "must be unlocked") unless unlock
  end

  def unlock_dependencies
    if self.completed_changed? && self.completed == true
      #need to factor into separate method so that unlock_dependants may be called for resetting a student dependency graph
      unlock_dependants
    end
  end

  def unlock_dependants
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

end