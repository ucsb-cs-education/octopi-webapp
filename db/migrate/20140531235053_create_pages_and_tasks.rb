class CreatePagesAndTasks < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.text :teacher_body
      t.text :student_body

      t.string :type

      #acts as list
      t.integer :position

      #For Module and Activity
      t.references :page

      t.timestamps
    end

    add_index :pages, :position

    create_table :tasks do |t|
      t.string :type

      t.string :title
      t.text :teacher_body
      t.text :student_body

      t.integer :position
      t.references :page

      t.timestamps
    end
    add_reference :laplaya_files, :task

  end
end
