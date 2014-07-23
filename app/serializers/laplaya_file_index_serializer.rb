class LaplayaFileIndexSerializer < ActiveModel::Serializer
  attributes :file_id, :file_name, :public, :note, :updated_at, :thumbnail

   #has_many :owners

  def file_id
    object.id
  end

  def filter(keys)
    keys = keys - [:updated_at, :thumbnail] if scope.nil?
    keys
  end

end
