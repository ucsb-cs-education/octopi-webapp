ActiveAdmin.register TestStudent do
  menu :if => proc { current_staff.super_staff? }

  actions :all, except: [:edit, :show, :new]
  permit_params :staff, :super_staff
  filter :school, :collection => proc { School.accessible_by(current_ability, :read) }
  filter :school_classes, :collection => proc { SchoolClass.where(school: School.accessible_by(current_ability, :read)) }

  index do
    if current_staff.super_staff?
      selectable_column
      id_column
      column :staff
      actions
    end
  end

  controller do
    def show
      staff = TestStudent.find(params[:id]).staff
      redirect_to admin_staff_path(staff)
    end
  end
end