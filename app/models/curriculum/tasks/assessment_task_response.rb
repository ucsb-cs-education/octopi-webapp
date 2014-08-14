class AssessmentTaskResponse < TaskResponse
  has_many :assessment_question_responses, foreign_key: :task_response_id, dependent: :destroy
  accepts_nested_attributes_for :assessment_question_responses

  def delete_children!
    assessment_question_responses.blank? ? true : assessment_question_responses.destroy_all
  end
end