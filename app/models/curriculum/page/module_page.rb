class ModulePage < Page
  resourcify
  acts_as_list scope: [:type]
  has_many :activity_pages, -> { order('position ASC') }, foreign_key: :page_id, dependent: :destroy
  has_and_belongs_to_many :school_classes, join_table: :module_pages_school_classes
  has_one :project_base_laplaya_file, foreign_key: :parent_id, dependent: :destroy
  has_one :sandbox_base_laplaya_file, foreign_key: :parent_id, dependent: :destroy

  alias_attribute :children, :activity_pages

  def update_with_children(params, ids)
    update_with_children_helper(ActivityPage, params, ids)
  end

  def is_accessible?(student, school_class)
    visible_to_students && school_class.module_pages.student_visible.include?(self)
  end


  def save_children_versions!(paper_trail_event, recursive)
    child_versions = []
    [[project_base_laplaya_file, :project_base_laplaya_file],
     [sandbox_base_laplaya_file, :sandbox_base_laplaya_file]].each do |child|
      child_versions.append(
          {
              type: child[1],
              version_id: (child[0].save_current_version_helper!(paper_trail_event, recursive)).id
          })
    end
    if recursive
      activity_pages.each do |child|
        child_versions.append(
            {
                type: :activity_page,
                version_id: (child.save_current_version_helper!(paper_trail_event, recursive)).id
            })
      end
    end
    child_versions.to_json
  end

  def restore_children_helper!(child_versions, duplicate)
    project_version = child_versions.select { |x| x[:type] == 'project_base_laplaya_file' }.first
    sandbox_version = child_versions.select { |x| x[:type] == 'sandbox_base_laplaya_file' }.first
    project_version = PaperTrail::Version.find_by(item_type: 'LaplayaFile', id: project_version[:version_id])
    sandbox_version = PaperTrail::Version.find_by(item_type: 'LaplayaFile', id: sandbox_version[:version_id])
    unless project_version && sandbox_version
      raise ActiveRecord::Rollback.new 'Number of child versions found does not match number saved!'
    end
    if duplicate
      activity_pages_versions = child_versions.select { |x| x[:type] == 'activity_page' }
      activity_pages_versions.each do |version|
        version = PaperTrail::Version.find_by(item_type: 'Page', id: version[:version_id])
        unless version
          raise ActiveRecord::Rollback.new "Couldn't find version for Activity Page with id: #{version[:version_id]}"
        end
        self.class.restore_version_helper(version, duplicate, self)
      end
    else
      if project_version.item_id != project_base_laplaya_file.id
        project_base_laplaya_file.destroy!
      end

      if sandbox_version.item_id != sandbox_base_laplaya_file.id
        sandbox_base_laplaya_file.destroy!
      end
    end
    override_parent = (duplicate) ? self : nil
    self.class.restore_version_helper(project_version, duplicate, override_parent)
    self.class.restore_version_helper(sandbox_version, duplicate, override_parent)
  end
end
