class CreateJoinTableAssessmentQuestionAssessmentQuestion < ActiveRecord::Migration
  def change
    create_table "question_relation", :force => true, :id => false do |t|
      t.integer "question_a_id", :null => false
      t.integer "question_b_id", :null => false
    end
  end
end
