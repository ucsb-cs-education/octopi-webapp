class CreateTimeInterval < ActiveRecord::Migration
  def change
    create_table :time_intervals do |t|
      t.integer :begin_time
      t.integer :end_time

      t.references :task_response
      t.timestamps
    end
  end
end
