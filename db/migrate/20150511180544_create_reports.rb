class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :name
      t.text :description
      t.timestamps
    end

    create_table(:reports_students, :id => false) do |t|
      t.references :student
      t.references :report
    end

    create_table(:reports_tasks, :id => false) do |t|
      t.references :task
      t.references :report
    end

    add_index(:reports_students, :student_id)
    add_index(:reports_tasks, :task_id)
    add_index(:reports_students, :report_id)
    add_index(:reports_students, [:report_id, :student_id], :unique => true )
  end
end
