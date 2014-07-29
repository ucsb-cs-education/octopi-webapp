module SchoolClassesHelper
  def student_count
    @school_class.students.count
  end

  def average_task_completion
    @responses.where(completed: true).count/(@tasks.count * @school_class.students.count).to_f
  end

  def average_task_unlock
    @unlocks.where(unlockable_type: Task).count/(@tasks.count * @school_class.students.count).to_f
  end

  def unlocked_count(task, collection)
    collection.where(unlockable: task).count
  end

  def percent_unlocked(task, collection)
    (100.0*(unlocked_count(task, collection).to_f/ @school_class.students.count)).to_s[0...4]
  end

  def completed_count(task)
    @responses.where(task: task, completed: true).count
  end

  def percent_completed(task)
    (100.0*(completed_count(task).to_f/ @school_class.students.count)).to_s[0...4]
  end

  def student_has_unlocked_activity?(student)
    @activity_unlocks.find_by(student: student, unlockable: @activity_page).nil? ? false : true
  end

  def get_visibility_of(student, task)
    if @task_unlocks.find_by(student: student, unlockable: task).nil?
      :locked
    else
      @responses.find_by(student: student, task: task, completed: true).nil? ? :visible : :completed
    end
  end

end
