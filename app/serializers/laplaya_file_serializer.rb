class LaplayaFileSerializer < ActiveModel::Serializer
  attributes :file_id, :file_name, :public, :note, :updated_at, :project, :media
  has_many :owners

  def file_id
    object.id
  end
end
