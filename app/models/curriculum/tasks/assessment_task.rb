class AssessmentTask < Task
  has_many :assessment_questions, -> { order('position ASC') }, foreign_key: :assessment_task_id
  alias_attribute :children, :assessment_questions

  def update_with_children(params, ids)
    update_with_children_helper(AssessmentQuestion, params, ids)
  end

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