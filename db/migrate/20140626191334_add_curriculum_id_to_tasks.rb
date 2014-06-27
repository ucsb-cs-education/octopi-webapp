class AddCurriculumIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :curriculum_id, :integer
    add_column :laplaya_files, :curriculum_id, :integer
  end
end
