module UnlocksHelper
  def student_has_unlocked_activity?(nothing)
    @unlock.nil? ? false : true
  end

  def get_visibility_of(student, task)
    :visible
  end

  def get_visibility_for_student_of(task)
    if @unlock.unlockable_type == "Task"
      :visible
    elsif @unlocks.find_by(unlockable: task).nil?
      :locked
    else
      :visible
    end
  end

  def load_unlocks
    @unlocks = Unlock.where(school_class: @school_class, student: @unlock.student)
  end
end