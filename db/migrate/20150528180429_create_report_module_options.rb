class CreateReportModuleOptions < ActiveRecord::Migration
  def change
    create_table :report_module_options do |t|
      t.references :report, index: true
      t.references :module_page, index: true
      t.boolean :include_sandbox
      t.boolean :include_project

      t.timestamps
    end
  end
end
