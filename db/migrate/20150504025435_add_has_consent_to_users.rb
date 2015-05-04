class AddHasConsentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_consent, :boolean, :default=>false
  end
end
