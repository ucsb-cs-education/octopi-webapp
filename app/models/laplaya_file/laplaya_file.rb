require 'xml'
require 'rexml/text'
require 'rexml/document'
require 'filterrific' 

class LaplayaFile < ActiveRecord::Base
  resourcify
  validates :file_name, presence: true, length: {maximum: 100}, allow_blank: false
  validate :manual_invalidator
  belongs_to :user
  alias_attribute :owner, :user

  before_validation :build_project_xml_parser
  before_validation :update_thumbnail_and_note
  before_validation :cloudify_project_xml, if: :should_cloudify?
  before_validation :cleanup_project_xml_parser
  before_validation :build_media_xml_parser, if: :should_cloudify?
  before_validation :cloudify_media_xml, if: :should_cloudify?
  before_validation :cleanup_media_xml_parser, if: :should_cloudify?

  has_paper_trail ignore: [:notes, :thumbnail], on: [:update, :destroy], :unless => Proc.new { |file| file.owner.is_a?(TestStudent) }

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

  def rename(new_name)
    if self.project
      doc = REXML::Document.new(self.project)
      REXML::XPath.first(doc, "//project").attributes["name"] = new_name
      self.project = doc.to_s
    end
    
    if self.media
      doc = REXML::Document.new(self.media)
      REXML::XPath.first(doc, "//media").attributes["name"] = new_name
      self.media = doc.to_s
    end
    
    update_attributes!(file_name: new_name)
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

  def should_cloudify?
    (Rails.application.config.auto_cloudify_laplaya_files || @_force_cloudify)
  end

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

  def escape_xml_names(str)
    #Some XML files don't properly escape things in the name
    #this regex searches for that and fixes it
    escape_name_regex = /((name|devName)\s*=\s*")(?<body>([^"]*(&(?!(apos|quot|lt|gt|amp|#xD|#126);)|'|<|>)[^"]*)+)"/
    str.match(escape_name_regex) do |match|
      orig_body = $~[:body]
      unescaped = REXML::Text.unnormalize(orig_body)
      while (new = REXML::Text.unnormalize(unescaped)) != unescaped do
        unescaped = new
      end
      new_body = REXML::Text.normalize(unescaped)
      str.gsub!('"'+orig_body+'"', '"'+new_body+'"')
      true
    end
  end

  def cleanup_xml_errors(str)
    #Some XML files have status wedged in without spaces
    #this searches for that, and fixes it
    status_regex = /"(status="[^"]*")/
    str = str.gsub(status_regex, '" \1 ')

    while escape_xml_names(str)
    end
    str
  end

  def parse(str, variable_name)
    begin
      parser = XML::Parser.string(str)
      parser.parse
    rescue LibXML::XML::Error => e
      str = cleanup_xml_errors(str)
      parser = XML::Parser.string(str)
      result = parser.parse
      self.send(variable_name+'=', str)
      result
    end
  end

  def build_project_xml_parser(force = false)
    force ||= @_force_cloudify
    if self.project.present? && (force || self.project_changed?)
      unless @_project_xml_content
        @_project_xml_content_changed = false
        begin
          @_project_xml_content = parse(self.project, 'project')
          unless @_project_xml_content.root.name == 'project'
            add_invalidation :project, 'root node must be a project'
            return
          end
          unless @_project_xml_content.root.attributes['name']
            add_invalidation :project, 'name must be present'
            return
          end
        rescue LibXML::XML::Error => e
          add_invalidation :project, e.message
          return false
        end
      end
    end
    true
  end

  def build_media_xml_parser(force = false)
    force ||= @_force_cloudify
    if self.media.present? && (force || self.media_changed?)
      unless @_media_xml_content
        @_media_xml_content_changed = false
        begin
          @_media_xml_content = parse(self.media, 'media')
          unless @_media_xml_content.root.name == 'media'
            add_invalidation :media, 'root node must be a media'
            return
          end
          unless @_media_xml_content.root.attributes['name']
            add_invalidation :media, 'name must be present'
            return
          end
        rescue LibXML::XML::Error => e
          add_invalidation :media, e.message
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
    @_media_xml_content = nil
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

  def cloudify_media_node(node, attr, type)
    if node
      data = node.attributes[attr]
      if data && data.start_with?('data') && data != 'data:,'
        asset = LaplayaFileAsset.asset_for_data_uri!(data, type)
        node.attributes[attr] = asset.data.url
        @_media_xml_content_changed = true
      end
    end
  end

  def cloudify_media_xml

    unless @_media_xml_content.nil?
      sounds = @_media_xml_content.find('sound')
      sounds.each do |sound|
        cloudify_media_node(sound, 'sound', 'sound')
      end
      sounds = nil
      costumes = @_media_xml_content.find('costume')
      costumes.each do |costume|
        cloudify_media_node(costume, 'image', 'costume')
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
        add_invalidation :project, e.message
        return false
      end
    end
    true
  end


  def add_invalidation(key, value)
    self.manual_invalidations << {key => value}
  end

  filterrific(
      default_filter_params: {sorted_by: 'id_asc'},
  available_filters:[
      :file_name,
      :sorted_by,
      :with_created_at_gte,
      :created_at_lt
  ])
  scope :sorted_by, lambda {|sort_option|
      direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
      order("laplaya_files.id #{direction}")
  }
  def self.options_for_sorted_by
    [
        ['File ID (Smallest First)', 'id_asc'],
        ['File ID (Largest First)', 'id_desc']
    ]
  end
  scope :with_created_at_gte, lambda { |reference_time|
                         where('laplaya_files.created_at >= ?', reference_time)
                       }

  # always exclude the upper boundary for semi open intervals
  scope :with_created_at_lt, lambda { |reference_time|
                        where('laplaya_files.created_at < ?', reference_time)
                      }
  scope :file_name, lambda {|query|

      return nil  if query.blank?
      query = query.to_s #in case a number is entered


      # condition query, parse into individual keywords
      terms = query.downcase.split(/\s+/)


      # replace "*" with "%" for wildcard searches,
      # append '%', remove duplicate '%'s



      # configure number of OR conditions for provision
      # of interpolation arguments. Adjust this if you
      # change the number of OR conditions.
      @flag = false
      terms.each do |term|
        if(term.to_i == 0)
          @flag = true #contains a string, don't try to search by #g
        end
      end
      if (@flag)
        terms = terms.map { |e|
          (e.gsub('*', '%') + '%').gsub(/%+/, '%')
        }
      num_or_conds = 2
      where(
          terms.map { |term|
            "(LOWER(laplaya_files.file_name) LIKE ? OR CAST(laplaya_files.id AS varchar) LIKE ?)"
          }.join(' AND '),
          *terms.map { |e| [e] * num_or_conds }.flatten
      )
      else
        num_or_conds = 3
        where(
            terms.map { |term|
              "(LOWER(laplaya_files.file_name) LIKE ? OR CAST(laplaya_files.id AS varchar) LIKE ? OR laplaya_files.user_id IN (Select CAST(? AS int) FROM users ))"
            }.join(' AND '),
            *terms.map { |e| [e] * num_or_conds }.flatten
        )
      end
    }

end
