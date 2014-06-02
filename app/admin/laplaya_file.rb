ActiveAdmin.register LaplayaFile do

index do
  selectable_column
  id_column
  column :file_name
  column :note
  column :public
  column :owner
  column :created_at
  column :updated_at
end

show do |file|

  attributes_table do
    row "File id" do
      file.id
    end
    [:file_name, :note, :public, :created_at, :updated_at].each do |attribute|
      row attribute
    end
  end
end

  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end

  controller do
    def scoped_collection
      LaplayaFile.includes(:owner)
    end
  end
  
end
