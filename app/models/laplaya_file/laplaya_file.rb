require 'xml'
class LaplayaFile < ActiveRecord::Base
  resourcify
  validates :file_name, presence: true, length: {maximum: 100}, allow_blank: false
  belongs_to :user
  alias_attribute :owner, :user
  before_validation :update_thumbnail_and_note
  has_paper_trail

  def to_s
    self.file_name
  end

  def clone(other_file)
    update_attributes!(file_name: other_file.file_name,
                       project: other_file.project,
                       media: other_file.media,
                       thumbnail: other_file.thumbnail,
                       note: other_file.note
    )
    self
  end

  # def owners
  #   User.with_role(:owner, self)
  # end
  #
  # def owner
  #   owners.first
  # end

  private
  def update_thumbnail_and_note
    if self.project_changed?
      begin
        parser = XML::Parser.string(self.project)
        content = parser.parse
        unless content.root.name == "project"
          errors.add(:project, "root node must be a project")
          return
        end
        unless content.root.attributes['name']
          errors.add(:project, "name must be present")
          return
        end
        self.file_name = content.root.attributes['name']
        note = content.find_first('notes')
        thumbnail = content.find_first('thumbnail')
        self.note = (note) ? note.content : ''
        self.thumbnail = (thumbnail) ? thumbnail.content : nil
      rescue LibXML::XML::Error => e
        errors.add(:project, e.message)
      end
    end
  end

end
