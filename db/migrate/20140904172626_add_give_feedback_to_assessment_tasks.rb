class AddGiveFeedbackToAssessmentTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :give_feedback, :boolean, default: false
  end
end
