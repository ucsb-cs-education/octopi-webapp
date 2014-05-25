ActiveAdmin.register Staff do
  remove_filter :users_roles
  permit_params :first_name, :last_name, :email, :password, :password_confirmation, :current_password
  menu if: proc {
    authorized?(:see_user_admin_menu)
  }

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :current_sign_in_at
    column :created_at
    actions
  end

  show do |user|

    attributes_table do
      # [:id, :first_name, :last_name, :email, :reset_password_sent_at User.attribute_names.each do |attribute|
      #   row attribute
      row :email
      row :first_name
      row :last_name
      # table_for user.roles.where(name: Role.main_roles) do
      #   column "Role" {|role| role.name }
      # end
      # row :roles do
      # end
      # table_for user.roles.where(role) do
      #   column "Role" do |role|
      #     role.name
      #   end
      #   column
      # end

      # active_admin_comments
    end
  end

# filter :roles, collection: [
# filter :email
# filter :current_sign_in_at
# filter :sign_in_count
# filter :created_at
  filter :unconfirmed

  form do |f|
    f.inputs "Staff Details" do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :password, required: false, label: "New password"
      f.input :password_confirmation, label: "New password confirmation"
      f.input :current_password, required: true if staff == current_staff
      # f.input :super_user, as: :boolean if can? :create_super_user, User
      f.input :roles, :as => :select, :collection => Role.global
    end

    f.actions
  end

  controller do
    def update_resource(object, attributes)
      update_method = attributes.first[:password].present? ? :update_attributes : :update_without_password
      object.send(update_method, *attributes)
    end
  end

end
