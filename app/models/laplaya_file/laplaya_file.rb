require 'xml'
class LaplayaFile < ActiveRecord::Base
  resourcify
  validates :file_name, presence: true, length: {maximum: 100}, allow_blank: false
  validate :manual_invalidator
  belongs_to :user
  alias_attribute :owner, :user

  before_validation :build_project_xml_parser
  before_validation :update_thumbnail_and_note
  before_validation :cloudify_project_xml, if: Rails.application.config.auto_cloudify_laplaya_files || @_force_cloudify
  before_validation :cleanup_project_xml_parser
  before_validation :build_media_xml_parser, if: Rails.application.config.auto_cloudify_laplaya_files || @_force_cloudify
  before_validation :cloudify_media_xml, if: Rails.application.config.auto_cloudify_laplaya_files || @_force_cloudify
  before_validation :cleanup_media_xml_parser, if: Rails.application.config.auto_cloudify_laplaya_files || @_force_cloudify

  has_paper_trail ignore: [:notes, :thumbnail], :on => [:update, :destroy], :unless => Proc.new { |file| file.owner.is_a?(TestStudent) }

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

  def cloudify!
    @_force_cloudify = true
    result = save!
    @_force_cloudify = false
    result
  end

  # def owners
  #   User.with_role(:owner, self)
  # end
  #
  # def owner
  #   owners.first
  # end

  def manual_invalidations
    @manual_invalidations ||= []
  end

  private

  def self.xml_info_regex
    /^<\?xml((?!\?>).)*\?>\s/
  end

  def manual_invalidator
    if self.manual_invalidations.any?
      self.manual_invalidations.each do |validation|
        if validation.is_a? Hash
          validation.each do |key, value|
            errors.add key, value
          end
        else
          raise StandardError('Invalid type in manual invalidations')
        end
      end
      false
    else
      true
    end
  end

  def build_project_xml_parser(force = false)
    force ||= @_force_cloudify
    if force || self.project_changed?
      unless @_project_xml_content
        @_project_xml_content_changed = false
        begin
          parser = XML::Parser.string(self.project)
          @_project_xml_content = parser.parse
          unless @_project_xml_content.root.name == 'project'
            self.manual_invalidations << {project: 'root node must be a project'}
            return
          end
          unless @_project_xml_content.root.attributes['name']
            self.manual_invalidations << {project: 'name must be present'}
            return
          end
        rescue LibXML::XML::Error => e
          self.manual_invalidations << {project: e.message}
          return false
        end
      end
    end
    true
  end

  def build_media_xml_parser(force = false)
    force ||= @_force_cloudify
    if force || self.media_changed?
      unless @_media_xml_content
        @_media_xml_content_changed = false
        begin
          parser = XML::Parser.string(self.media)
          @_media_xml_content = parser.parse
          unless @_media_xml_content.root.name == 'media'
            self.manual_invalidations << {media: 'root node must be a media'}
            return
          end
          unless @_media_xml_content.root.attributes['name']
            self.manual_invalidations << {media: 'name must be present'}
            return
          end
        rescue LibXML::XML::Error => e
          self.manual_invalidations << {media: e.message}
          return false
        end
      end
    end
    true
  end

  def cleanup_project_xml_parser
    @_project_xml_content = nil
    true
  end

  def cleanup_media_xml_parser
    @_project_xml_content = nil
    true
  end

  def cloudify_project_xml
    #Right now, we are not cloudifying the project XML, because they change way too often
    #Theoretically we could extract this out and have it be attached to each save and delete every time it changes
    #But that sounds too hard for little reward. Right now, Just save it in the project XML and deal with it

    # def cloudify_node(node, type)
    #   if node
    #     data = node.content
    #     if data && data.start_with?('data')
    #       asset = ::LaplayaFileAsset.asset_for_data_uri!(data, type)
    #       node.content = asset.data.url
    #       @_project_xml_content_changed = true
    #     end
    #   end
    # end
    #
    # unless @_project_xml_content.nil?
    #   thumbnail = @_project_xml_content.find_first('thumbnail')
    #   pentrails = @_project_xml_content.find_first('stage/pentrails')
    #   cloudify_node(thumbnail, 'thumbnail')
    #   cloudify_node(pentrails, 'pentrails')
    #   if @_project_xml_content_changed
    #     self.project = @_project_xml_content.to_s(indent: false).sub(LaplayaFile.xml_info_regex, '')
    #   end
    # end
    true
  end

  def cloudify_media_xml
    def cloudify_node(node, attr, type)
      if node
        data = node.attributes[attr]
        if data && data.start_with?('data')
          asset = LaplayaFileAsset.asset_for_data_uri!(data, type)
          node.attributes[attr] = asset.data.url
          @_media_xml_content_changed = true
        end
      end
    end

    unless @_media_xml_content.nil?
      sounds = @_media_xml_content.find('sound')
      sounds.each do |sound|
        cloudify_node(sound, 'sound', 'sound')
      end
      sounds = nil
      costumes = @_media_xml_content.find('costume')
      costumes.each do |costume|
        cloudify_node(costume, 'image', 'costume')
      end
      costumes = nil
      if @_media_xml_content_changed
        self.media = @_media_xml_content.to_s(indent: false).sub(LaplayaFile.xml_info_regex, '')
      end
    end
    true
  end

  def update_thumbnail_and_note
    unless @_project_xml_content.nil?
      begin
        self.file_name = @_project_xml_content.root.attributes['name']
        note = @_project_xml_content.find_first('notes')
        thumbnail = @_project_xml_content.find_first('thumbnail')
        self.note = (note) ? note.content : ''
        self.thumbnail = (thumbnail) ? thumbnail.content : nil
      rescue LibXML::XML::Error => e
        self.manual_invalidations << {project: e.message}
        return false
      end
    end
    true
  end

end
