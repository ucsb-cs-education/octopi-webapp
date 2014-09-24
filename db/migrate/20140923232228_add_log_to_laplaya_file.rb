class AddLogToLaplayaFile < ActiveRecord::Migration
  def change
    add_column :laplaya_files, :log, :text, array: true, default: []
    add_column :laplaya_files, :save_uuid, :string, default: ''
  end
end
