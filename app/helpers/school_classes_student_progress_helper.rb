module SchoolClassesStudentProgressHelper
  def number_of_tasks_completed
    @responses.where(completed: true).count
  end

  def number_of_tasks
    @tasks.count
  end

  def percent_done
    (100.0*(@responses.where(completed: true).count.to_f/ number_of_tasks)).to_s[0...4]
  end

  def student_has_unlocked_activity?(activity)
    @unlocks.find_by(student: @student, unlockable: activity).nil? ? false : true
  end
end