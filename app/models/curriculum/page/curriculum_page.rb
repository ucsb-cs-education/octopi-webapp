class CurriculumPage < Page
  resourcify
  has_many :module_pages, -> { order('position ASC') }, foreign_key: :page_id, dependent: :destroy
  has_and_belongs_to_many :schools, join_table: :curriculum_pages_schools
  alias_attribute :children, :module_pages
  undef :visible_to
  undef :visible_to=

  def update_with_children(params, ids)
    update_with_children_helper(ModulePage, params, ids)
  end

  def to_s
    title
  end

end
