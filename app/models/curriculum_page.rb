class CurriculumPage < Page
  resourcify
  has_many :module_pages, -> { order('position ASC') }, foreign_key: :page_id
  alias_attribute :children, :module_pages
  after_create {update_attribute(:curriculum_id, id)}

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

end
