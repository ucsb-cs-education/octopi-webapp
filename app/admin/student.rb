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
        column 'School Classes' do |school_class|
          link_to school_class.name, [:admin, school_class]
        end
      end
    end
  end


  member_action :change_class, method: :post, as: 'change_class' do
    @student = resource
    original_class = SchoolClass.find(params[:current_class])
    new_class = SchoolClass.find(params[:new_class])
    preserve = params[:preserve]
    if @student.change_school_class(original_class, new_class, preserve)
      flash[:notice] = "#{@student.name} successfully moved #{'with all their data ' unless preserve}from #{original_class.name} to #{new_class.name}."
    else
      flash[:error] = 'An error occured during removal.'
    end
    redirect_to action: :edit
  end

  member_action :remove_class, method: :post, as: 'remove_class' do
    @student = resource
    school_class = SchoolClass.find(params[:class])
    delete_data = params[:delete_data] === 'true'
    success = if delete_data
                @student.delete_all_data_for(school_class)
              else
                @student.soft_remove_from(school_class)
              end
    if success
      flash[:notice] = "#{@student.name} successfully removed #{'with all their data ' if delete_data}from #{school_class.name}."
    else
      flash[:error] = 'An error occured during removal.'
    end
    redirect_to action: :edit
  end

  form partial: 'form'

  controller do
    before_action :load_student_classes, only: [:edit]

    def set_paloma
      js :edit
    end

    def load_student_classes
      @student = resource
      @student_current_classes = [OpenStruct.new({name: 'Move from class', id: nil})]
      @student_removable_classes = [OpenStruct.new({name: 'Remove from class', id: nil})]
      @student_noncurrent_classes = [OpenStruct.new({name: 'To class', id: nil})]
      if can? :update, SchoolClass
        @student.school_classes.each { |school_class|
          @student_current_classes.push(*[
              OpenStruct.new({name: school_class.name, id: school_class.id})
          ])
          @student_removable_classes.push(*[
              OpenStruct.new({name: school_class.name, id: school_class.id})
          ]) }
        #'ERROR:  bind message supplies 2 parameters, but prepared statement "a24" requires 1' without plucking ids
        @student.school.school_classes.where.not(id: @student.school_classes.pluck(:id)).each { |school_class|
          @student_noncurrent_classes.push(*[
              OpenStruct.new({name: school_class.name, id: school_class.id})
          ]) }
      end
    end

  end
end
