class AddIndexsToLaplayaFiles < ActiveRecord::Migration
  def change
    add_index :laplaya_files, ['type', 'user_id', 'parent_id']
  end
end
