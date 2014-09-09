class AddSpecialAttributesToTasksAndPages < ActiveRecord::Migration
  def change
    add_column :tasks, :special_attributes, :text, default: "[]"
    add_column :pages, :special_attributes, :text, default: "[]"
  end
end
