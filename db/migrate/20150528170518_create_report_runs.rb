class CreateReportRuns < ActiveRecord::Migration
  def change
    create_table :report_runs do |t|
      t.references :report, index: true

      t.timestamps
    end
  end
end
