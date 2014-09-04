class AssessmentTaskResponse < TaskResponse
  has_many :assessment_question_responses, foreign_key: :task_response_id, dependent: :destroy
  accepts_nested_attributes_for :assessment_question_responses

  def is_accessible?(student, school_class)
    task.visible_to_students && task.give_feedback && (:completed == task.get_visibility_status_for(student, school_class))
  end

  def unlock_dependencies(force = false)
    self.completed = true
    super
  end

end