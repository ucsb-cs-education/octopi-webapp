module SchoolClassesHelper
  def student_count
    @school_class.students.count
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

  def student_has_unlocked_activity?(student, activity)
    @activity_unlocks.find_by(student: student, unlockable: activity).nil? ? false : true
  end
end
