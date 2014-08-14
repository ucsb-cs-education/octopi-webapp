class CreateActivityUnlocksAndAddUnlockedAndHiddenColumnToTaskResponses < ActiveRecord::Migration
  def change
    create_table :activity_unlocks do |t|
      t.boolean :hidden, default: false
      t.boolean :unlocked, default: false

      t.references :activity_page
      t.references :student
      t.references :school_class

      t.timestamps
    end

    add_column :task_responses, :unlocked, :boolean, default: false
    add_column :task_responses, :hidden, :boolean, default: false
  end
end
