include OctopiAdminControllerBase
ActiveAdmin.register School do

  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :name, :ip_range, :student_remote_access_allowed
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end

  # filter :roles, collection: [
  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
  # filter :created_at
  insert_controller_actions
  controller do
    def default_update_path
      admin_schools_path
    end
  end


end
