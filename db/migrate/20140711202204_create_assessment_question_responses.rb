class CreateAssessmentQuestionResponses < ActiveRecord::Migration
  def change
    create_table :assessment_question_responses do |t|
      t.references :task_response
      t.references :assessment_question
      t.text :selected

      t.timestamps
    end
  end
end
