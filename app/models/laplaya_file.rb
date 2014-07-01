require 'xml'
class LaplayaFile < ActiveRecord::Base
  resourcify
  validates :file_name, presence: true, length: {maximum: 100}, allow_blank: false
  before_validation :update_thumbnail_and_note

  def to_s
    self.file_name
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
