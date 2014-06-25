class ActivityPage < Page
  resourcify
  belongs_to :module_page, foreign_key: :page_id
  acts_as_list scope: [:type, :page_id]
  has_many :tasks, -> { order('position ASC') }, foreign_key: :page_id

  alias_attribute :children, :tasks
  alias_attribute :parent, :module_page
  after_create {update_attribute(:curriculum_id, parent.curriculum_id)}

  def update_with_children(params, ids)
    transaction do
      child_ids = children.pluck(:id).map { |x| x.to_s }
      raise(ArgumentError, 'update_children_order ids must match children ids') unless same_elements?(child_ids, ids)
      if child_ids != ids
        children = {}
        ids.each_with_index.map { |x, i| children[x] = {position: i+1} }
        Task.update(children.keys, children.values)
      end
      update_attributes!(params)
    end
  end

  private
  def update_curriculum_id
    self.curriculum_id = parent.curriculum_id
  end

end

