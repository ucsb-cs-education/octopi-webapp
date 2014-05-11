class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.string :name,                   null: false, default: ""
      t.string :ip_range
      t.integer :students_count,        null: false, default: 0
      t.boolean :student_remote_access_allowed,      default: false

      t.timestamps
    end

    create_table :school_classes do |t|
      t.references :school
      t.string :name,                     null: false, default: ""
      t.boolean :student_remote_access_allowed,      default: false
      t.timestamps
    end

    create_table :students do |t|
      t.string :first_name,                   null: false, default: ""
      t.string :last_name,                    null: false, default: ""
      t.string :login_name,                   null: false, default: ""
      t.string :password_digest
      t.string :remember_token
      t.references :school

      t.timestamps
    end

    create_table(:school_classes_students, :id => false) do |t|
      t.references :student
      t.references :school_class
    end

    create_table :snap_files do |t|
      t.string :file_name,  null: false, default: ""
      t.binary :xml,        limit: 10.megabytes
      t.boolean :public,    default: false

      t.timestamps
    end

    add_index(:school_classes_students, :student_id)
    add_index(:school_classes_students, :school_class_id)
    add_index(:school_classes_students, [:student_id, :school_class_id], :unique => true)


    add_index(:students, :school_id)
    add_index(:students, [ :school_id, :login_name ])

  end
end

