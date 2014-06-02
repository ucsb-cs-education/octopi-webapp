class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.string :name,                   null: false, default: ""
      t.string :ip_range
      t.integer :students_count,        null: false, default: 0
      t.boolean :student_remote_access_allowed,      default: false

      t.timestamps
    end

    add_reference :users, :school

    create_table :school_classes do |t|
      t.references :school
      t.string :name,                     null: false, default: ""
      t.boolean :student_remote_access_allowed,      default: false
      t.timestamps
    end

    create_table(:school_classes_students, :id => false) do |t|
      t.references :student
      t.references :school_class
    end

    create_table :laplaya_files do |t|
      t.string :file_name,  null: false, default: ""
      t.binary :project,        limit: 10.megabytes
      t.binary :media,          limit: 10.megabytes
      t.binary :thumbnail,      limit: 2.megabytes
      t.text   :note,       null: false, default: ""
      t.boolean :public,    default: false

      #STI for BaseFile
      t.string :type

      t.timestamps
    end

    add_index(:school_classes_students, :student_id)
    add_index(:school_classes_students, :school_class_id)
    add_index(:school_classes_students, [:student_id, :school_class_id], :unique => true)


    add_index(:users, :school_id)
    add_index(:users, [ :school_id, :login_name ])

  end
end

