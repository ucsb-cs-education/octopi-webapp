class CreateTaskResponseFeedbacks < ActiveRecord::Migration
  def change
    create_table :task_response_feedbacks do |t|
      t.references :task_response, index: true
      t.references :task, index: true
      t.string :feedback

      t.timestamps
    end
  end
end
