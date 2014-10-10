ActiveAdmin.register SchoolClass do
  actions :all, except: [:new]
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
    attributes_table do
      [:name, :school].each do |attribute|
        row attribute
      end
      table_for school_class.students.where(type: 'Student').order('first_name ASC') do
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

  controller do
    def edit
      redirect_to edit_school_class_path(SchoolClass.find(params['id']))
    end
  end

end
