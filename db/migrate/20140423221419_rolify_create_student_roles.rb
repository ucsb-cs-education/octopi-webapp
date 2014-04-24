class RolifyCreateStudentRoles < ActiveRecord::Migration
  def change
    create_table(:student_roles) do |t|
      t.string :name
      t.references :resource, :polymorphic => true

      t.timestamps
    end

    create_table(:students_student_roles, :id => false) do |t|
      t.references :student
      t.references :student_role
    end

    add_index(:student_roles, :name)
    add_index(:student_roles, [ :name, :resource_type, :resource_id ])
    add_index(:students_student_roles, [ :student_id, :student_role_id ])
  end
end
