class CreateUnlocks < ActiveRecord::Migration
  def change
    create_table :unlocks do |t|
      t.boolean :hidden
      t.integer :unlockable_id
      t.string :unlockable_type

      t.references :student
      t.references :school_class

      t.timestamps
    end
    add_index :unlocks, [:unlockable_id, :unlockable_type, :student_id, :school_class_id], unique: true, name: "unlock_index"
  end
end
