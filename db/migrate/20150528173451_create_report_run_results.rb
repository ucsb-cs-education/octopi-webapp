class CreateReportRunResults < ActiveRecord::Migration
  def change
    create_table :report_run_results do |t|
      t.references :report_run, index: true
      t.references :laplaya_file, index: true
      t.text :json_results

      t.timestamps
    end
  end
end
