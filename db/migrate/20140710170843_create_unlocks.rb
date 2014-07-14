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
  end
end
