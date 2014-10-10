class AddChildVersionsToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :child_versions, :text, default: 'false'
  end
end
