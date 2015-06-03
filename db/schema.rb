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

ActiveRecord::Schema.define(version: 20150603200326) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "activity_dependencies", force: true do |t|
    t.integer "task_prerequisite_id"
    t.integer "activity_dependant_id"
  end

  add_index "activity_dependencies", ["activity_dependant_id"], name: "index_activity_dependencies_on_activity_dependant_id", using: :btree
  add_index "activity_dependencies", ["task_prerequisite_id", "activity_dependant_id"], name: "activity_dependency_index", unique: true, using: :btree
  add_index "activity_dependencies", ["task_prerequisite_id"], name: "index_activity_dependencies_on_task_prerequisite_id", using: :btree

  create_table "assessment_question_responses", force: true do |t|
    t.integer  "task_response_id"
    t.integer  "assessment_question_id"
    t.text     "selected"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assessment_questions", force: true do |t|
    t.string   "title"
    t.text     "question_body"
    t.text     "answers"
    t.text     "question_type"
    t.integer  "position"
    t.integer  "assessment_task_id"
    t.integer  "curriculum_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ckeditor_assets", force: true do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resource_id"
    t.string   "resource_type"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree
  add_index "ckeditor_assets", ["resource_id", "resource_type"], name: "index_ckeditor_assets_on_resource_id_and_resource_type", using: :btree

  create_table "curriculum_pages_schools", id: false, force: true do |t|
    t.integer "school_id",          null: false
    t.integer "curriculum_page_id", null: false
  end

  create_table "laplaya_analysis_files", force: true do |t|
    t.binary   "data"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "laplaya_file_assets", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "asset_type"
    t.string   "data_fingerprint"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
  end

  create_table "laplaya_files", force: true do |t|
    t.string   "file_name",     default: "",    null: false
    t.binary   "project"
    t.binary   "media"
    t.binary   "thumbnail"
    t.text     "note",          default: "",    null: false
    t.boolean  "public",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "curriculum_id"
    t.string   "type"
    t.integer  "user_id"
    t.text     "log",           default: [],                 array: true
    t.string   "save_uuid",     default: ""
  end

  add_index "laplaya_files", ["type", "parent_id"], name: "index_laplaya_files_on_type_and_parent_id", using: :btree
  add_index "laplaya_files", ["type", "user_id", "parent_id"], name: "index_laplaya_files_on_type_and_user_id_and_parent_id", using: :btree
  add_index "laplaya_files", ["user_id"], name: "index_laplaya_files_on_user_id", using: :btree

  create_table "module_pages_school_classes", id: false, force: true do |t|
    t.integer "school_class_id", null: false
    t.integer "module_page_id",  null: false
  end

  create_table "pages", force: true do |t|
    t.string   "title"
    t.text     "teacher_body"
    t.text     "student_body"
    t.string   "type"
    t.integer  "position"
    t.integer  "page_id"
    t.integer  "curriculum_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "designer_note"
    t.boolean  "visible_to_students", default: true
    t.boolean  "visible_to_teachers", default: true
  end

  add_index "pages", ["position"], name: "index_pages_on_position", using: :btree

  create_table "report_module_options", force: true do |t|
    t.integer  "report_id"
    t.integer  "module_page_id"
    t.boolean  "include_sandbox"
    t.boolean  "include_project"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "report_module_options", ["module_page_id"], name: "index_report_module_options_on_module_page_id", using: :btree
  add_index "report_module_options", ["report_id"], name: "index_report_module_options_on_report_id", using: :btree

  create_table "report_run_results", force: true do |t|
    t.integer  "report_run_id"
    t.integer  "laplaya_file_id"
    t.text     "json_results"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_processed"
  end

  add_index "report_run_results", ["laplaya_file_id"], name: "index_report_run_results_on_laplaya_file_id", using: :btree
  add_index "report_run_results", ["report_run_id", "is_processed"], name: "index_report_run_results_on_report_run_id_and_is_processed", using: :btree
  add_index "report_run_results", ["report_run_id"], name: "index_report_run_results_on_report_run_id", using: :btree

  create_table "report_runs", force: true do |t|
    t.integer  "report_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "report_runs", ["report_id"], name: "index_report_runs_on_report_id", using: :btree

  create_table "reports", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "code_filename"
    t.text     "code_contents"
  end

  create_table "reports_students", id: false, force: true do |t|
    t.integer "student_id"
    t.integer "report_id"
  end

  add_index "reports_students", ["report_id", "student_id"], name: "index_reports_students_on_report_id_and_student_id", unique: true, using: :btree
  add_index "reports_students", ["report_id"], name: "index_reports_students_on_report_id", using: :btree
  add_index "reports_students", ["student_id"], name: "index_reports_students_on_student_id", using: :btree

  create_table "reports_tasks", id: false, force: true do |t|
    t.integer "task_id"
    t.integer "report_id"
  end

  add_index "reports_tasks", ["task_id"], name: "index_reports_tasks_on_task_id", using: :btree

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

  create_table "task_dependencies", force: true do |t|
    t.integer "prerequisite_id"
    t.integer "dependant_id"
  end

  add_index "task_dependencies", ["dependant_id"], name: "index_task_dependencies_on_dependant_id", using: :btree
  add_index "task_dependencies", ["prerequisite_id", "dependant_id"], name: "index_task_dependencies_on_prerequisite_id_and_dependant_id", unique: true, using: :btree
  add_index "task_dependencies", ["prerequisite_id"], name: "index_task_dependencies_on_prerequisite_id", using: :btree

  create_table "task_response_feedbacks", force: true do |t|
    t.integer  "task_response_id"
    t.integer  "task_id"
    t.string   "feedback"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "task_response_feedbacks", ["task_id"], name: "index_task_response_feedbacks_on_task_id", using: :btree
  add_index "task_response_feedbacks", ["task_response_id"], name: "index_task_response_feedbacks_on_task_response_id", using: :btree

  create_table "task_responses", force: true do |t|
    t.integer  "student_id"
    t.integer  "task_id"
    t.integer  "school_class_id"
    t.string   "type"
    t.boolean  "completed",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "version_date"
  end

  add_index "task_responses", ["student_id", "school_class_id", "task_id"], name: "task_response_tri_index", unique: true, using: :btree

  create_table "tasks", force: true do |t|
    t.string   "type"
    t.string   "title"
    t.text     "teacher_body"
    t.text     "student_body"
    t.integer  "position"
    t.integer  "page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "curriculum_id"
    t.text     "designer_note"
    t.boolean  "visible_to_students", default: true
    t.boolean  "visible_to_teachers", default: true
    t.boolean  "demo",                default: false
  end

  create_table "unlocks", force: true do |t|
    t.boolean  "hidden"
    t.integer  "unlockable_id"
    t.string   "unlockable_type"
    t.integer  "student_id"
    t.integer  "school_class_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "unlocks", ["unlockable_id", "unlockable_type", "student_id", "school_class_id"], name: "unlock_index", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "type"
    t.string   "first_name",             default: "",    null: false
    t.string   "last_name",              default: "",    null: false
    t.string   "email"
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "login_name",             default: "",    null: false
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
    t.integer  "test_student_id"
    t.boolean  "has_consent",            default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["school_id", "login_name"], name: "index_users_on_school_id_and_login_name", using: :btree
  add_index "users", ["school_id"], name: "index_users_on_school_id", using: :btree
  add_index "users", ["test_student_id"], name: "index_users_on_test_student_id", using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",                        null: false
    t.integer  "item_id",                          null: false
    t.string   "event",                            null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "child_versions", default: "false"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
