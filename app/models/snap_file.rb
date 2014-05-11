class SnapFile < ActiveRecord::Base
  resourcify
  obfuscate_id
  validates :file_name, presence: true, length: { maximum: 50 }

  def to_xml(options={})
    self.xml
  end

  def as_json(options={})
    options.merge!( except:  [:id] , methods: [:id_encoded, :xml_path])
    super(options)
  end

end
