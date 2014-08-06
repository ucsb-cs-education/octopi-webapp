class OfflineTask < Task

  def is_accessible?(student, school_class)
    visible_to_students && (:visible == get_visibility_status_for(student, school_class))
  end

  def get_visibility_status_for(student, school_class)
    if (unlock = find_unlock_for(student, school_class)).nil?
      :locked
    else
      unlock.hidden ? false : :visible
    end
  end
end