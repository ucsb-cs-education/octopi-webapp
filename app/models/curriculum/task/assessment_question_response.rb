class AssessmentQuestionResponse < ActiveRecord::Base
  belongs_to :task_response
  belongs_to :assessment_question

end