class RemoveColumnLaplayaFileIdFromTaskResponse < ActiveRecord::Migration
  def change
    remove_column :task_responses, :laplaya_file_id
  end
end
