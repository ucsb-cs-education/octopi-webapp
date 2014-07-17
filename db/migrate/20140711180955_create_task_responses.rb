class CreateTaskResponses < ActiveRecord::Migration
  def change
    create_table :task_responses do |t|
      t.references :student, index: true
      t.references :task, index: true
      t.references :school_class, index: true
      t.references :laplaya_file, index: true
      t.string :type
      t.boolean :completed, :default => false

      t.timestamps
    end
    add_index :task_responses, [:student_id, :school_class_id, :task_id], unique: true, name: 'task_response_tri_index'
  end
end
