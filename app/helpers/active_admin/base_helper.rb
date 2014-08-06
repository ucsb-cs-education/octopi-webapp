module ActiveAdmin::BaseHelper
  def devise_mapping
    @devise_mapping ||= request.env['devise.mapping']
    @devise_mapping ||= Devise.mappings[:staff]
  end

  def resource_name
    devise_mapping.name
  end

  def resource_class
    devise_mapping.to
  end
end
