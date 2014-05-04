class RolifyCreateRoles < ActiveRecord::Migration
  def change
    create_table(:roles) do |t|
      t.string :name
      t.references :resource, :polymorphic => true

      t.timestamps
    end

    add_index(:roles, :name)
    add_index(:roles, [ :name, :resource_type, :resource_id ])


    create_table(:users_roles, :id => false) do |t|
      t.references :user
      t.references :role
    end

    add_index(:users_roles, [ :user_id, :role_id ])

    create_table(:students_roles, :id => false) do |t|
      t.references :student
      t.references :role
    end

    add_index(:students_roles, [ :student_id, :role_id ])

  end
end