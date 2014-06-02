class ModulePage < Page
  belongs_to :curriculum_page, foreign_key: :page_id
  acts_as_list scope: [:type, :page_id]
  has_many :activity_pages, -> { order('position ASC') },  foreign_key: :page_id

  alias_attribute :children, :activity_pages

  def update_children_order(ids)
    child_ids = children.pluck(:id).map { |x| x.to_s }
    raise(ArgumentError, 'update_children_order ids must match children ids') unless same_elements?(child_ids, ids)
    children = {}
    ids.each_with_index.map { |x, i| children[x] = {position: i+1} }
    ActivityPage.update(children.keys, children.values)
  end
end
