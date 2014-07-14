class TaskResponse < ActiveRecord::Base
  belongs_to :school_class
  belongs_to :student
  belongs_to :task
  after_save :unlock_dependencies


  #def type_must_be_correct
   # errors.add(:type, "must be either laplaya_task_response or assessment_task_response") unless type=="laplaya_task_response" || type=="assessment_task_response"
  #end

  def unlock_dependencies
    if self.completed_changed? == true
      Unlock.find_by(student_id: student.id,
                     school_class_id: school_class.id,
                     unlockable_type: "Task",
                     unlockable_id:task.id).update_attribute(:hidden,true)
      task.activity_dependants.each{|x|
        if check_prereqs(x) == true
          Unlock.create(student_id: student.id, school_class_id: school_class.id, unlockable_type: "Page", unlockable_id: x.id)
        end
      }
      task.dependants.each {|x|
        if check_prereqs(x) == true
          if Unlock.find_by(student_id: student.id,
                            school_class_id: school_class.id,
                            unlockable_type: "Page",
                            unlockable_id: x.activity_page) != nil
            Unlock.create(student_id: student.id, school_class_id: school_class.id, unlockable_type: "Task", unlockable_id: x.id)
          end
        end
        }
    end
  end



  def check_prereqs(model)
    model.prerequisites.each{|y|
      prereq_response = TaskResponse.find_by(student_id: student.id, school_class_id: school_class.id, task: y.id)
      if prereq_response == nil || prereq_response.completed != true
        return false
      end
    }
    return true
  end

end