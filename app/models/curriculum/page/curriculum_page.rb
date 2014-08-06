class CurriculumPage < Page
  resourcify
  has_many :module_pages, -> { order('position ASC') }, foreign_key: :page_id, dependent: :destroy
  has_and_belongs_to_many :schools, join_table: :curriculum_pages_schools
  alias_attribute :children, :module_pages
  undef :visible_to
  undef :visible_to=

  def update_with_children(params, ids)
    transaction do
      child_ids = children.pluck(:id).map { |x| x.to_s }
      raise(ArgumentError, 'update_children_order ids must match children ids') unless same_elements?(child_ids, ids)
      if child_ids != ids
        children = {}
        ids.each_with_index.map { |x, i| children[x] = {position: i+1} }
        ModulePage.update(children.keys, children.values)
      end
      update_attributes!(params)
    end
  end

  def to_s
    title
  end

end
