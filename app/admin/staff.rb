ActiveAdmin.register Staff do
  filter :roles
  remove_filter :users_roles
  permit_params do
    params = [:first_name, :last_name, :email, :password, :password_confirmation]
    if %w(edit update).include?(request.filtered_parameters['action']) && resource && resource == current_staff
      params.push :current_password
    elsif %w(new create).include?(request.filtered_parameters['action'])
      params.push :assign_a_random_password
    end
    params.push basic_roles: [] if can? :add_basic_roles, Staff
    params.push :super_staff if can? :create_super_staff, :any
    params
  end

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
        column 'Roles' do |role|
          role.to_label
        end
      end
    end
  end

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


    def assign_roles
      new_roles = Role.array_to_roles(params[:staff][:basic_roles]).to_a
      school_teacher_roles = []
      if can? :add_teacher, School
        school_teacher_roles = Role.where(name: :teacher,
                                          resource: School.accessible_by(current_ability, :add_teacher))
      end
      school_class_teacher_roles = []
      if can? :add_class_teacher, SchoolClass
        school_class_teacher_roles = Role.where(name: :teacher,
                                                resource: SchoolClass.accessible_by(current_ability, :add_class_teacher))
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
      school_class_teacher_roles&=new_roles
      new_roles = school_teacher_roles.to_set.
          merge(school_admin_roles).
          merge(curriculum_roles).
          merge(school_class_teacher_roles).to_a
      new_roles.map! { |x| x.id }
      params[:staff][:basic_roles] = new_roles
      unless new_roles.any? || current_staff.super_staff?
        {
            basic_roles: "Cannnot #{params[:action]} a user without a role you manage"
        }
      end
    end

    def update(options={}, &block)
      object = resource

      unless (invalidations = assign_roles).nil?
        object.manual_invalidations << invalidations
      end
      if update_resource(object, resource_params)
        options[:location] ||= smart_resource_url
      end
      respond_with_dual_blocks(object, options, &block)
    end

    def update_resource(object, attributes)
      staff_params = attributes.first
      if object == current_staff
        if staff_params[:password].present? || staff_params[:current_password].present?
          if object.update_with_password(staff_params)
            sign_in(object, bypass: true)
          end
        else
          staff_params.delete(:current_password)
          object.update_without_password(staff_params)
        end
      else
        unless staff_params[:password].present?
          staff_params.delete(:password)
          staff_params.delete(:password_confirmation) unless staff_params[:password_confirmation].present?
        end
        object.update_attributes(staff_params)
      end
    end

    def create(options={}, &block)
      if resource_params.first[:assign_a_random_password] === '1'
        resource_params.first[:assign_a_random_password] = true
      end
      invalidations = assign_roles
      object = build_resource
      unless (invalidations).nil?
        object.manual_invalidaitons << invalidations
      end
      if create_resource(object)
        options[:location] ||= smart_resource_url
      end
      respond_with_dual_blocks(object, options, &block)
    end

  end

end
