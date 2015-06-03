class AddResultsProcessed < ActiveRecord::Migration
  def change
    add_column :report_run_results, :is_processed, :boolean
    add_index :report_run_results, [:report_run_id, :is_processed]
  end
end
