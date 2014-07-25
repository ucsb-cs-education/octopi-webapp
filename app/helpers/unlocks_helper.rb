module UnlocksHelper
  def student_has_unlocked_activity?(nothing)
    @unlock.nil? ? false : true
  end

end