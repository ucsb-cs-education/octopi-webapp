class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.string :name,                   null: false, default: ""
      t.string :ip_range
      t.boolean :student_remote_access_allowed,      default: false

      t.timestamps
    end

    create_table :school_classes do |t|
      t.references :school
      t.boolean :student_remote_access_allowed,      default: false
      t.timestamps
    end

    create_table :students do |t|
      t.string :name,                   null: false, default: ""
      t.string :password_digest
      t.string :remember_token
      t.references :school

      t.timestamps
    end

    create_table(:school_class_students, :id => false) do |t|
      t.references :student
      t.references :school_class
    end

    add_index(:school_class_students, :student_id)
    add_index(:school_class_students, :school_class_id)


    add_index(:students, :school_id)
    add_index(:students, [ :school_id, :name ])

    # This should not be validated, we just want this reference here so that for administrators and teachers
    # that are associated with a single school, we can display that as part of their profile.
    # Additionally, this allows us to get all the teachers and administrators unique to just a school
    add_reference(:users, :school)
  end
end

