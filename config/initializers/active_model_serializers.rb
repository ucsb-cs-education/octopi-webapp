if defined? ActiveModel::Serializer
  ActiveModel::Serializer.setup do |config|
    config.embed = :ids
    config.embed_in_root = false
  end
  ActiveModel::Serializer.root = false
  ActiveModel::ArraySerializer.root = false

end