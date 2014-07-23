ActiveAdmin.register Staff do
  filter :roles
  remove_filter :users_roles
  permit_params :first_name, :last_name, :email, :password, :password_confirmation, :current_password, :super_staff, basic_roles: []
  menu if: proc {
    authorized?(:see_user_admin_menu)
  }

  batch_action :confirmed do |selection|
    Staff.find(selection).each do |t|
      t.confirm!
      t.save
    end
    redirect_to :back
  end
  batch_action :unconfirmed do |selection|
    Staff.find(selection).each do |t|
      t.confirmed_at = nil
      t.save
    end
    redirect_to :back
  end


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

    attributes_table :first_name, :last_name, :email do
      table_for staff.roles do
        column "Roles" do |role|
          role.to_label
        end
      end

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

  form partial: 'form'

  controller do
    before_action :set_role_names, only: [:create, :new, :update, :edit]

    def set_paloma
      js :edit
    end

    def set_role_names
      @new_role_names = [OpenStruct.new({name: 'Select a role', id: nil})]
      if can? :update, School
        @new_role_names.push(*[
            OpenStruct.new({name: 'Teacher (school)', id: :teacher}),
            OpenStruct.new({name: 'Teacher (school class)', id: :teacher_class}),
            OpenStruct.new({name: 'School Admin', id: :school_admin})])

      end
      if can? :update, CurriculumPage
        @new_role_names << OpenStruct.new({name: 'Curriculum Designer', id: :curriculum_designer})
      end
      @new_role_values = [
          OpenStruct.new({name: 'Please select a role first', id: nil})
      ]
    end

    def update(options={}, &block)
      object = resource

      if verify_roles object
        if update_resource(object, resource_params)
          options[:location] ||= smart_resource_url
        end
      end

      respond_with_dual_blocks(object, options, &block)
    end

    def update_resource(object, attributes)
      staff_params = attributes[0]
      if attributes.first[:password].present? || attributes.first[:current_password].present?
        object.update_attributes(*attributes)
      else
        attributes.first.delete(:current_password)
        object.update_without_password(*attributes)
      end
    end

    def verify_roles(object)
      new_roles = Role.array_to_roles(params[:staff][:basic_roles]).to_a
      school_teacher_roles = []
      if can? :add_teacher, School
        school_teacher_roles = Role.where(name: :teacher,
                                          resource: School.accessible_by(current_ability, :add_teacher))
      end
      school_admin_roles = []
      if can? :add_school_admin, School
        school_admin_roles = Role.where(name: :school_admin,
                                        resource: School.accessible_by(current_ability, :add_school_admin))
      end
      curriculum_roles = []
      if can? :add_designer, CurriculumPage
        curriculum_roles = Role.where(name: :curriculum_designer, resource_type: 'CurriculumPage', resource: CurriculumPage.accessible_by(current_ability, :add_designer).pluck(:id))
      end
      school_teacher_roles&=new_roles
      school_admin_roles&=new_roles
      curriculum_roles&=new_roles
      new_roles = school_teacher_roles.to_set.merge(school_admin_roles).merge(curriculum_roles).to_a
      if new_roles.any? || current_staff.super_staff?
        params[:staff][:basic_roles] = new_roles.map { |x| x.id }
      else
        object.errors.add :basic_roles, "Cannot #{params[:action]} a user without a role you manage"
        false
      end
    end

    def create(options={}, &block)
      object = build_resource
      if verify_roles object
        if create_resource(object)
          options[:location] ||= smart_resource_url
        end
      end

      respond_with_dual_blocks(object, options, &block)
    end

  end

end
