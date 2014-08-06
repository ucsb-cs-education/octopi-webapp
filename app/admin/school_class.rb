ActiveAdmin.register SchoolClass do
  actions :all, except: [:edit, :new]
  permit_params :name, :ip_range, :student_remote_access_allowed, students: []
  filter :school, :collection => proc { School.accessible_by(current_ability, :read) }

  index do
    selectable_column
    id_column
    column :name
    column :school
    actions
  end

  show :title => :name do
    attributes_table :name, :school do
      table_for school_class.students.order('first_name ASC') do
        column 'Students' do |student|
          link_to student.name, [:admin, student]
        end
      end
    end
  end

  form do |f|
    f.inputs 'School details' do
      f.input :name
    end
    f.actions
  end

end
