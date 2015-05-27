class AddCodeToReports < ActiveRecord::Migration
  def up
    add_attachment :reports, :code
  end

  def down
    remove_attachment :reports, :code
  end
end
