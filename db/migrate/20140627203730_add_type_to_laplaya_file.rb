class AddTypeToLaplayaFile < ActiveRecord::Migration
  def change
    add_column :laplaya_files, :type, :string
  end
end
