class CurriculumPage < Page
  resourcify
  has_many :module_pages, -> { order('position ASC') }, foreign_key: :page_id, dependent: :destroy
  has_many :ckeditor_assets, :class_name => 'Ckeditor::Asset', as: :resource
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

  def save_children_versions!(paper_trail_event, recursive)
    if recursive
      child_versions = []
      module_pages.each do |child|
        child_versions.append(child.save_current_version_helper!(paper_trail_event, recursive))
      end
      child_versions.map { |x| {type: :module_page, version_id: x.id} }.to_json
    else
      'false'
    end
  end


  def restore_children_helper!(child_versions, duplicate)
    if duplicate
      module_pages_versions = child_versions.select { |x| x[:type] == 'module_page' }
      module_pages_versions.each do |version|
        version = PaperTrail::Version.find_by(item_type: 'Page', id: version[:version_id])
        unless version
          raise ActiveRecord::Rollback.new "Couldn't find version for Module Page with id: #{version[:version_id]}"
        end
        self.class.restore_version_helper(version, duplicate, self)
      end
    end
  end
end
