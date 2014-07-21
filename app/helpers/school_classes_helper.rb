module SchoolClassesHelper
  def student_count
    @school_class.students.count
  end

  def unlocked_count(task)
    @unlocks.where(unlockable: task).count
  end

  def percent_unlocked(task)
    (100.0*(unlocked_count(task).to_f/ @school_class.students.count)).to_s[0...4]
  end

  def completed_count(task)
    @responses.where(task: task, completed: true).count
  end

  def percent_completed(task)
    (100.0*(completed_count(task).to_f/ @school_class.students.count)).to_s[0...4]
  end
end
