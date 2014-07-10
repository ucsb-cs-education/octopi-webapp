class CreateJoinTableSchoolCurriculumPage < ActiveRecord::Migration
  def change
    create_join_table :schools, :curriculum_pages do |t|
      # t.index [:school_id, :curriculum_page_id]
      # t.index [:curriculum_page_id, :school_id]
    end
  end
end
