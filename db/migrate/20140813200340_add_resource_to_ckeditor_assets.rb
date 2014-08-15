class AddResourceToCkeditorAssets < ActiveRecord::Migration
  def change
    add_reference :ckeditor_assets, :resource, polymorphic: true, index: true
  end
end
