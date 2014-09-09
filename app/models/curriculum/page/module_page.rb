class ModulePage < Page
  resourcify
  belongs_to :curriculum_page, foreign_key: :page_id
  acts_as_list scope: [:type, :page_id]
  has_many :activity_pages, -> { order('position ASC') }, foreign_key: :page_id, dependent: :destroy
  has_and_belongs_to_many :school_classes, join_table: :module_pages_school_classes
  has_one :project_base_laplaya_file, foreign_key: :parent_id, dependent: :destroy
  has_one :sandbox_base_laplaya_file, foreign_key: :parent_id, dependent: :destroy
  validate :special_attributes_parseable

  alias_attribute :children, :activity_pages
  alias_attribute :parent, :curriculum_page


  def update_with_children(params, ids)
    update_with_children_helper(ActivityPage, params, ids)
  end

  def is_accessible?(student, school_class)
    visible_to_students && school_class.module_pages.student_visible.include?(self)
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
