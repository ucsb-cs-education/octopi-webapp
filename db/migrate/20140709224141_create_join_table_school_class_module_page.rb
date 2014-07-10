class CreateJoinTableSchoolClassModulePage < ActiveRecord::Migration
  def change
    create_join_table :school_classes, :module_pages do |t|
      # t.index [:school_class_id, :module_page_id]
      # t.index [:module_page_id, :school_class_id]
    end
  end
end
