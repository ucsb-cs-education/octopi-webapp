class CreateActivityDependencies < ActiveRecord::Migration
  def change
    create_table :activity_dependencies,:force => true, :id => false do |t|
      t.integer :task_prerequisite_id
      t.integer :activity_dependant_id
    end
    add_index :activity_dependencies, :task_prerequisite_id
    add_index :activity_dependencies, :activity_dependant_id
    add_index :activity_dependencies, [:task_prerequisite_id, :activity_dependant_id], unique: true,  name: 'activity_dependency_index'
  end
end
