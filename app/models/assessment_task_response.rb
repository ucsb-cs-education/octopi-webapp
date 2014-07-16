class AssessmentTaskResponse < TaskResponse
  has_many :assessment_question_responses, foreign_key: :task_response_id
  accepts_nested_attributes_for :assessment_question_responses


  def unlock_dependencies
    self.completed = true
    super
  end

end