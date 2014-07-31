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

  def student_has_unlocked_activity?(student)
    @activity_unlocks.exists?(student: student, unlockable: @activity_page) ? true : false
  end

end
