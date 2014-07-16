class TaskResponse < ActiveRecord::Base
  belongs_to :school_class
  belongs_to :student
  belongs_to :task
  before_save :unlock_dependencies
  validate :task_is_unlocked

  def task_is_unlocked
    errors.add(:taskresponse, "must be unlocked") unless find_unlock
  end

  def unlock_dependencies
    if self.completed_changed? == true
      find_unlock.update_attribute(:hidden, true) if task.is_a?(AssessmentTask)
      task.activity_dependants.each { |x|
        if check_prereqs(x) == true
          Unlock.create(student: student, school_class: school_class, unlockable: x)
        end
      }
      task.dependants.each { |x|
        if check_prereqs(x) == true
          if x.find_unlock_for(student, school_class).nil?
            Unlock.create(student_id: student.id, school_class_id: school_class.id, unlockable_type: "Task", unlockable_id: x.id)
          end
        end
      }
    end
  end

  def find_unlock
    Unlock.find_by(student: student.id, school_class: school_class.id, unlockable: task)
  end

  def check_prereqs(model)
    model.prerequisites.each { |y|
      unless y==self.task
        prereq_response = TaskResponse.find_by(student: student, school_class: school_class, task: y)

        if prereq_response == nil || prereq_response.completed != true
          return false
        end
      end
    }
    return true
  end

end