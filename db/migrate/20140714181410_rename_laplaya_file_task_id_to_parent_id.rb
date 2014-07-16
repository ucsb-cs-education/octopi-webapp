class RenameLaplayaFileTaskIdToParentId < ActiveRecord::Migration
  def change
    change_table :laplaya_files do |t|
      t.rename :task_id, :parent_id
    end
    add_index :laplaya_files, [:parent_id, :type], unique: true
  end


end
