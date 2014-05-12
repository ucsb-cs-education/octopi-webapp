# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140412152713) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "school_classes", force: true do |t|
    t.integer  "school_id"
    t.string   "name",                          default: "",    null: false
    t.boolean  "student_remote_access_allowed", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "school_classes_students", id: false, force: true do |t|
    t.integer "student_id"
    t.integer "school_class_id"
  end

  add_index "school_classes_students", ["school_class_id"], name: "index_school_classes_students_on_school_class_id", using: :btree
  add_index "school_classes_students", ["student_id", "school_class_id"], name: "index_school_classes_students_on_student_id_and_school_class_id", unique: true, using: :btree
  add_index "school_classes_students", ["student_id"], name: "index_school_classes_students_on_student_id", using: :btree

  create_table "schools", force: true do |t|
    t.string   "name",                          default: "",    null: false
    t.string   "ip_range"
    t.integer  "students_count",                default: 0,     null: false
    t.boolean  "student_remote_access_allowed", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "snap_files", force: true do |t|
    t.string   "file_name",  default: "",    null: false
    t.binary   "project"
    t.binary   "media"
    t.binary   "thumbnail"
    t.text     "note",       default: "",    null: false
    t.boolean  "public",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "students", force: true do |t|
    t.string   "first_name",      default: "", null: false
    t.string   "last_name",       default: "", null: false
    t.string   "login_name",      default: "", null: false
    t.string   "password_digest"
    t.string   "remember_token"
    t.integer  "school_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "students", ["school_id", "login_name"], name: "index_students_on_school_id_and_login_name", using: :btree
  add_index "students", ["school_id"], name: "index_students_on_school_id", using: :btree

  create_table "students_roles", id: false, force: true do |t|
    t.integer "student_id"
    t.integer "role_id"
  end

  add_index "students_roles", ["student_id", "role_id"], name: "index_students_roles_on_student_id_and_role_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name",             default: "", null: false
    t.string   "last_name",              default: "", null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
