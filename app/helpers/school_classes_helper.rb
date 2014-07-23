module SchoolClassesHelper
  def student_count
    @school_class.students.count
  end

  def unlocked_count(task,collection)
    collection.where(unlockable: task).count
  end

  def percent_unlocked(task,collection)
    (100.0*(unlocked_count(task,collection).to_f/ @school_class.students.count)).to_s[0...4]
  end

  def completed_count(task)
    @responses.where(task: task, completed: true).count
  end

  def percent_completed(task)
    (100.0*(completed_count(task).to_f/ @school_class.students.count)).to_s[0...4]
  end

  def get_visibility_of(task, student, school_class)
    task.get_visibility_status_for(student,school_class)
  end

  def student_has_unlocked_activity(student, activity)
    if @activity_unlocks.nil? then
      @unlock.nil? ? false : true
    else
      @activity_unlocks.find_by(student: student, unlockable: activity).nil? ? false : true
    end
  end
end
