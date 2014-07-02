class CreateAssessmentQuestionsTable < ActiveRecord::Migration
  def change
    create_table :assessment_questions do |t|
      t.string :title
      t.text :question_body
      t.text :answers
      t.text :questionType #singleAnswer or multipleAnswers
      #acts as list
      t.integer :position

      #For Module and Activity
      t.references :assessment_task
      #For permissions, overall curriculum_id
      t.integer :curriculum_id

      t.timestamps
    end

    add_column :tasks, :curriculum_id, :integer
  end
end
