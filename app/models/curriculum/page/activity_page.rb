class ActivityPage < Page
  resourcify
  belongs_to :module_page, foreign_key: :page_id
  acts_as_list scope: [:type, :page_id]
  has_many :tasks, -> { order('position ASC') }, foreign_key: :page_id, dependent: :destroy

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

  def save_children_versions!(paper_trail_event, recursive)
    if recursive
      child_versions = []
      tasks.each do |child|
        child_versions.append(child.save_current_version_helper!(paper_trail_event, recursive))
      end
      child_versions.map { |x| {type: :task, version_id: x.id} }.to_json
    else
      'false'
    end
  end

  def restore_children_helper!(child_versions, duplicate)
    if duplicate
      task_versions = child_versions.select { |x| x[:type] == 'task' }
      task_versions.each do |version|
        version = PaperTrail::Version.find_by(item_type: 'Task', id: version[:version_id])
        unless version
          raise ActiveRecord::Rollback.new "Couldn't find version for Task with id: #{version[:version_id]}"
        end
        self.class.restore_version_helper(version, duplicate, self)
      end
    end
  end
end

