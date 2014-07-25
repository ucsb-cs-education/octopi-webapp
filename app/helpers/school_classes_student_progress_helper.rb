module SchoolClassesStudentProgressHelper
  def number_of_tasks_completed
    @responses.where(completed: true).count
  end

  def number_of_tasks
    @tasks.count
  end

  def number_unlocked
    @unlocks.where(unlockable_type: Task).count
  end

  def number_of_tasks_in_progress
    number_unlocked - number_of_tasks_completed
  end

  def number_of_locked_tasks
    number_of_tasks - number_unlocked
  end

  def student_has_unlocked_activity?(activity)
    @unlocks.find_by(student: @student, unlockable: activity).nil? ? false : true
  end
end