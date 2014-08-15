class CreateLaplayaFileAsset < ActiveRecord::Migration
  def change
    create_table :laplaya_file_assets do |t|
      t.timestamps
      t.string :asset_type
      t.string :data_fingerprint
    end
    add_attachment :laplaya_file_assets, :data
  end
end
