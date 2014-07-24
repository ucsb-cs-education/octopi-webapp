module UnlocksHelper
  def student_has_unlocked_activity?(student, activity)
    @unlock.nil? ? false : true
  end
end