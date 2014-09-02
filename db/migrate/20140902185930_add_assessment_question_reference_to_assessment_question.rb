class AddAssessmentQuestionReferenceToAssessmentQuestion < ActiveRecord::Migration
  def change
    add_reference :assessment_questions, :assessment_question
  end
end
