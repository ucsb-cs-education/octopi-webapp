ActiveAdmin.register SchoolClass do
  actions :all, except: [:edit, :new]
  permit_params :name, :ip_range, :student_remote_access_allowed,students: []
  filter :school, :collection=> proc{School.accessible_by(current_ability, :read)}
  # remove_filter :schoolclasses_students
  show :title => :name do
    attributes_table :name, :school do
      table_for school_class.students.order('first_name ASC') do
        column "Students" do |student|
          link_to student.name, [:admin, student]
        end
      end
    end
  end

  form do |f|
    f.inputs "School details" do
      f.input :name
      #f.input :student_remote_access_allowed
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
