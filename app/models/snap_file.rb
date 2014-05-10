class SnapFile < ActiveRecord::Base
  resourcify
  obfuscate_id

  def to_xml(options={})
    self.xml
  end

  def as_json(options={})
    options.merge!( except:  [:id] , methods: [:id_encoded, :xml_path])
    super(options)
  end

end
