ActiveAdmin.register Student do
  actions :all, except: [:new]
  filter :school, :collection => proc { School.accessible_by(current_ability, :read) }
  filter :school_classes, :collection => proc { SchoolClass.where(school: School.accessible_by(current_ability, :read)) }

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


  form partial: 'form'

  controller do
    before_action :load_student_classes, only: [:create, :new, :update, :edit]

    def set_paloma
      js :edit
    end

    def load_student_classes
      @student = Student.find(params[:id])
      @student_current_classes = [OpenStruct.new({name: 'Move from class', id: nil})]
      @student_removable_classes = [OpenStruct.new({name: 'Remove from class', id: nil})]
      @student_noncurrent_classes = [OpenStruct.new({name: 'To class', id: nil})]
      if can? :update, School
        @student.school_classes.each { |school_class|
          @student_current_classes.push(*[
              OpenStruct.new({name: school_class.name, id: school_class.id})
          ])
          @student_removable_classes.push(*[
              OpenStruct.new({name: school_class.name, id: school_class.id})
          ])}
        #'ERROR:  bind message supplies 2 parameters, but prepared statement "a24" requires 1' without plucking ids
        @student.school.school_classes.where.not(id: @student.school_classes.pluck(:id)).each { |school_class|
          @student_noncurrent_classes.push(*[
              OpenStruct.new({name: school_class.name, id: school_class.id})
          ]) }
      end

    end
  end
end
