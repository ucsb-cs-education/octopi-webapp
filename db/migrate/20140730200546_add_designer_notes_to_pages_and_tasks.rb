class AddDesignerNotesToPagesAndTasks < ActiveRecord::Migration
  def change
    add_column :pages, :designer_note, :text
    add_column :tasks, :designer_note, :text
  end
end
