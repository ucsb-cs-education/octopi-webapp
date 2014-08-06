class AddVisibleToPagesAndTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :visible_to_students, :boolean, default: true
    add_column :tasks, :visible_to_teachers, :boolean, default: true
    add_column :pages, :visible_to_students, :boolean, default: true
    add_column :pages, :visible_to_teachers, :boolean, default: true
    add_column :tasks, :demo, :boolean, default: false
  end
end
