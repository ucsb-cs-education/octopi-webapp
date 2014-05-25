ActiveAdmin.register Student do

  remove_filter :users_roles
  remove_filter :students_school_classes
  remove_filter :school_classes_users
  remove_filter :users_school_classes

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :login_name
    actions
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
  
end
