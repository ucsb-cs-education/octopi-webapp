class AddUnlocksIndex < ActiveRecord::Migration
  def change
    add_index :unlocks, [:unlockable_id, :unlockable_type, :student_id, :school_class_id], unique: true, name: 'unlock_index'
  end
end
