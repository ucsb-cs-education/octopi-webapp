class AddRandomizeQuestionOrderToAssessmentQuestions < ActiveRecord::Migration
  def change
    add_column :assessment_questions, :randomize, :boolean, default: true
  end
end
