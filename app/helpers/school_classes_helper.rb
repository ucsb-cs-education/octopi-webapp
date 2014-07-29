module SchoolClassesHelper
  def student_count
    @school_class.students.count
  end

  def average_task_completion
    @responses.where(completed: true).count/(@tasks.count * @school_class.students.count).to_f
  end

  def average_task_unlock
    @unlocks.where(unlockable_type: Task).count/( @tasks.count * @school_class.students.count).to_f
  end

  def unlocked_count(task, collection)
    collection.where(unlockable: task).count
  end

  def task_unlocked_count(task)
    task.unlocks.count
  end

  def percent_unlocked(task, collection)
    (100.0*(unlocked_count(task, collection).to_f/ @school_class.students.count)).to_s[0...4]
  end

  def completed?(task)
    TaskResponse.where(task: task, school_class: @school_class, completed: true)==@students.count
  end

  def percent_completed(task)
    (100.0*(completed_count(task).to_f/ @school_class.students.count)).to_s[0...4]
  end

  def student_has_unlocked_activity?(student)
    @activity_unlocks.exists?(student: student, unlockable: @activity_page) ? true : false
  end

  def repeated_name?(task)
    @activity_page.tasks.where(title: task.title).count>1 ? true : false
  end

  def get_visibility_of(student, task)
    unless task.unlocks.exists?(student: student, unlockable: task, school_class: @school_class)
      :locked
    else
      student.task_responses.exists?(school_class: @school_class, task: task, completed: true) ? :completed : :visible
    end
  end

end
