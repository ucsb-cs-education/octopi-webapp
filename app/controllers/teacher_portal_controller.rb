class TeacherPortalController < ApplicationController
  load_and_authorize_resource :school_class, :except => [ :index ]
  
  
  def index
    authenticate_staff!
    if current_staff.super_staff?
      schools_for_user = School.all.reorder(:name)
    else
      schools_for_user = School.with_role(:teacher, current_staff).reorder(:name)
    end

    if @schools.empty?
      flash[:error] = ('You are not a teacher at any schools!'
                       + 'You must be a teacher to access this page.')
      redirect_to staff_root_path

    else
      @schools = schools_for_user.collect do |school|
        record = {id: school.id, name: school.name, admins: school.school_admins, classes: school.school_classes }
        if not current_staff.super_staff?
          record[:classes] = school.classes.select { |c| current_staff.has_role? :teacher, c}
        end
        record
      end
  end

  def edit_class
  end

  def check_progress
  end


end
