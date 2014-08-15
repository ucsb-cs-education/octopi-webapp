require 'data_uri'
class LaplayaFileAsset < ActiveRecord::Base
  has_attached_file :data
  validates_attachment_content_type :data, content_type: %w(image/jpeg image/gif image/png audio/x-wav)

  def self.asset_for_data_uri!(data_uri, type)
    data = get_data_from_data_uri_string(data_uri)
    fingerprint = Digest::MD5.hexdigest(data)
    record = LaplayaFileAsset.find_or_initialize_by(data_fingerprint: fingerprint, asset_type: type)
    if record.new_record?
      record.data = get_file_handle_for_data(data)
      record.save!
    end
    record
  end

  def self.get_file_handle_from_data_uri(data_uri)
    get_file_handle_for_data(get_data_from_data_uri_string(data_uri))
  end

  def self.get_data_from_data_uri_string(data_uri)
    URI::Data.new(data_uri).data
  end

  def self.get_file_handle_for_data(data)
    StringIO.new(data)
  end

end
