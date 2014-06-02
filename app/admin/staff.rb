ActiveAdmin.register Staff do
  remove_filter :users_roles
  permit_params :first_name, :last_name, :email, :password, :password_confirmation, :current_password, :super_staff
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
    column :confirmed_at
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
  scope :all, :default => true
  scope :unconfirmed
  scope :confirmed

  form do |f|
    f.inputs "Staff Details" do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :password, required: false, label: "New password"
      f.input :password_confirmation, label: "New password confirmation"
      if staff == current_staff
        f.input :current_password
      else
        f.input :roles, :as => :select, :collection => Role.global, label: "Global roles"
      end
      f.input :super_staff, as: :boolean if can? :create_super_staff, User
    end

    f.actions
  end

  controller do
    def update_resource(object, attributes)
      if attributes.first[:password].present? || attributes.first[:current_password].present?
        object.update_attributes(*attributes)
      else
        attributes.first.delete(:current_password)
        object.update_without_password(*attributes)
      end
    end
  end

end
