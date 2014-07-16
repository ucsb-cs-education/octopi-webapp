class ActivityPage < Page
  resourcify
  belongs_to :module_page, foreign_key: :page_id
  acts_as_list scope: [:type, :page_id]
  has_many :tasks, -> { order('position ASC') }, foreign_key: :page_id

  has_many :activity_dependencies, foreign_key: :activity_dependant_id, dependent: :destroy
  has_many :prerequisites, :through => :activity_dependencies, source: :task_prerequisite

  alias_attribute :children, :tasks
  alias_attribute :parent, :module_page

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

  def depend_on(prereq)
    activity_dependencies.create!(task_prerequisite: prereq)
  end

<<<<<<< HEAD
  def find_unlock_for(student, school_class)
    Unlock.find_for(student, school_class, self)
=======
  def depends_on?(prereq)
    self.prerequisites.include?(prereq)
  end

  def find_unlock_for(student,school_class)
    Unlock.find_by(student: student, school_class: school_class, unlockable: self)
>>>>>>> Made a way to see prerequisites and dependencies and am slowly figuring out the forms to edit them
  end

  def get_locked_status_for(student, school_class)
    find_unlock_for(student, school_class).nil?
  end

end

