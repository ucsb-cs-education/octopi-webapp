class LaplayaFileSerializer < ActiveModel::Serializer
  attributes :file_id, :file_name, :public, :note, :updated_at, :project, :media, :can_update
  has_many :owners

  def file_id
    object.id
  end

  def can_update
    Ability.new(scope).can?(:update, object)
  end


end
