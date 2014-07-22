class AddUserReferenceToLaplayaFiles < ActiveRecord::Migration
  def change
    add_reference :laplaya_files, :user, index: true
    add_index :laplaya_files, [:type, :parent_id]
  end
end
