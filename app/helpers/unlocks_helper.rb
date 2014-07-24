module UnlocksHelper
  def student_has_unlocked_activity?(student, activity)
    @unlock.nil? ? false : true
  end

  def this_student_has_unlocked_this_activity?(activity)
    @unlock.nil? ? false : true
  end

end