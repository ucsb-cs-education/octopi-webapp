require_relative '20150527201723_add_code_to_reports'
class ChangeReportCodeToDbFile < ActiveRecord::Migration
  def change
    revert AddCodeToReports
    add_column :reports, :code_filename, :text
    add_column :reports, :code_contents, :text
  end
end
