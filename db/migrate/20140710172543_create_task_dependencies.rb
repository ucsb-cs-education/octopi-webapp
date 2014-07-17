class CreateTaskDependencies < ActiveRecord::Migration
  def change
    create_table :task_dependencies, :force => true do |t|
      t.integer :prerequisite_id
      t.integer :dependant_id
    end
    add_index :task_dependencies, :prerequisite_id
    add_index :task_dependencies, :dependant_id
    add_index :task_dependencies, [:prerequisite_id, :dependant_id], unique: true
  end
end
