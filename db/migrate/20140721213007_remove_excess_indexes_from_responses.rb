class RemoveExcessIndexesFromResponses < ActiveRecord::Migration
  def change
    remove_index :task_responses, column: :laplaya_file_id
    remove_index :task_responses, column: :school_class_id
    remove_index :task_responses, column: :student_id
    remove_index :task_responses, column: :task_id
    remove_index :laplaya_files, name: 'index_laplaya_files_on_parent_id_and_type'
  end
end
