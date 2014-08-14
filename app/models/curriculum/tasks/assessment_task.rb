class AssessmentTask < Task
  has_many :assessment_questions, -> { order('position ASC') }, foreign_key: :assessment_task_id
  alias_attribute :children, :assessment_questions

  def update_with_children(params, ids)
    update_with_children_helper(AssessmentQuestion, params, ids)
  end

  def is_accessible?(student, school_class)
    visible_to_students && (:visible == get_visibility_status_for(student, school_class))
  end

  def create_basic_response_for(student, school_class)
    AssessmentTaskResponse.create!(student: student, school_class: school_class, task: self, unlocked: (prerequisites.empty? ? true : false))
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