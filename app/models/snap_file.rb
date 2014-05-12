require 'xml'
class SnapFile < ActiveRecord::Base
  resourcify
  obfuscate_id
  validates :file_name, presence: true, length: {maximum: 50}
  before_validation :update_thumbnail_and_note

  def as_json(options={})
    options.merge!(except: [:id], methods: [:file_id]) do |key, oldval, newval|
      (oldval.is_a?(Array) ? (oldval + newval) : (newval << oldval)).uniq
    end
    super(options)
  end

  def file_id
    self.to_param
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
