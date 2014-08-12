class AddVersionDateToTaskResponses < ActiveRecord::Migration
  def change
    add_column :task_responses, :version_date, :datetime
  end
end
