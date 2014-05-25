require 'xml'
class LaplayaFile < ActiveRecord::Base
  resourcify
  validates :file_name, presence: true, length: {maximum: 50}
  before_validation :update_thumbnail_and_note

  def to_s
    self.file_name
  end

  def owners
    User.with_role(:owner, self)
  end

  private
    def update_thumbnail_and_note
      if self.project_changed?
        parser =  XML::Parser.string(self.project)
        content = parser.parse
        self.file_name = content.root.attributes['name']
        note = content.find_first('notes')
        thumbnail = content.find_first('thumbnail')
        self.note = (note) ? note.content : ''
        self.thumbnail = (thumbnail) ? thumbnail.content : nil
      end
    end

end
