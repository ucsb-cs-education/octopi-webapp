class RemoveCurriculum < ActiveRecord::Migration
  def change
    remove_reference :ckeditor_assets, :resource, polymorphic: true, index: true
    remove_column :assessment_questions, :curriculum_id
    remove_column :pages, :curriculum_id
    remove_column :tasks, :curriculum_id
    remove_column :laplaya_files, :curriculum_id
  end
end
