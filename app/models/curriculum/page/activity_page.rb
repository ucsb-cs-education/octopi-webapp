class ActivityPage < Page
  resourcify
  belongs_to :module_page, foreign_key: :page_id
  acts_as_list scope: [:type, :page_id]
  has_many :tasks, -> { order('position ASC') }, foreign_key: :page_id, dependent: :destroy
  validate :special_attributes_parseable

  has_many :activity_dependencies, foreign_key: :activity_dependant_id, dependent: :destroy
  has_many :prerequisites, :through => :activity_dependencies, source: :task_prerequisite

  alias_attribute :children, :tasks
  alias_attribute :parent, :module_page

  def update_with_children(params, ids)
    update_with_children_helper(Task, params, ids)
  end

  def depend_on(prereq)
    activity_dependencies.create!(task_prerequisite: prereq)
  end

  def find_unlock_for(student, school_class)
    unlock = Unlock.find_for(student, school_class, self)
    if unlock.nil? && prerequisites.empty?
      unlock = Unlock.create(student: student, school_class: school_class, unlockable: self)
    end
    unlock
  end

  def is_accessible?(student, school_class)
    visible_to_students && (:visible == get_visibility_status_for(student, school_class))
  end

  def get_visibility_status_for(student, school_class)
    if find_unlock_for(student, school_class).nil?
      :locked
    else
      :visible
    end
  end

  private
  def special_attributes_parseable
    begin
      json = JSON.parse(special_attributes)
      json.each { |j|
        errors.add(:json, "Improperly formatted attributes") if j['value'] == nil || j['text'] == nil
      }
    rescue
      errors.add(:json, "Improperly formatted attributes")
    end
  end

end

