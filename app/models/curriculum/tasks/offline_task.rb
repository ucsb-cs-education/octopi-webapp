class OfflineTask < Task

  def is_accessible?(student, school_class)
    visible_to_students && (:visible == get_visibility_status_for(student, school_class))
  end

  def create_basic_response_for(student, school_class)
    TaskResponse.create!(student: student, school_class: school_class, task: self, unlocked: (prerequisites.empty? ? true : false))
  end

  def get_visibility_status_for(student, school_class)
    response = find_response_for(student, school_class)
    if response.nil? || !response.unlocked
      :locked
    else
      response.hidden ? false : :visible
    end
  end
end