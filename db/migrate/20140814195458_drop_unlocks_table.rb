class DropUnlocksTable < ActiveRecord::Migration
  def change
    drop_table :unlocks
  end
end
