ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  show do |user|

    attributes_table do
      User.attribute_names.each do |attribute|
        row attribute
      end
      # row :email
      # row :first_name
      # row :last_name
    #   row :alias
    #   row :bio
      row :global_admin do
        user.has_role?(:global_admin).to_s
      end
      # table_for  user.roles.where(role) do
      #   column "Role" do |role|
      #     role.name
      #   end
      #   column
      # end
    end

    active_admin_comments
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "User Details" do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :global_admin, as: :boolean if can? :create_global_admin, User
    end

    f.actions
  end

end
