ActiveAdmin.register Student do
  actions :all, except: [:new]
  filter :school, :collection => proc {School.accessible_by(current_ability, :read)}
  filter :school_classes, :collection => proc {SchoolClass.where(school: School.accessible_by(current_ability, :read))}

  permit_params :first_name, :last_name, :login_name, :password,
                :password_confirmation, :current_password, :super_staff

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :login_name
    actions
  end

  show do
    attributes_table :first_name, :last_name, :login_name, :school do
      table_for student.school_classes do
        column "School Classes" do |school_class|
            link_to school_class.name, [:admin, school_class]
        end
      end
    end
  end

  form do |f|
    f.inputs "Student details" do
      f.input :first_name
      f.input :last_name
      f.input :login_name
      f.input :password
      f.input :password_confirmation
    end
    f.actions
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
