class CreateTimeInterval < ActiveRecord::Migration
  def change
    add_column :task_responses, :time_intervals, :text, default: "[]"
    create_table :time_intervals do |t|
      t.integer :begin_time
      t.integer :end_time

      t.references :task_response
      t.timestamps
    end
  end
end
