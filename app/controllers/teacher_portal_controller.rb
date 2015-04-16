class TeacherPortalController < ApplicationController
  load_and_authorize_resource :school_class, :except => [ :index ]
   
  def index
    authenticate_staff!
    if current_staff.super_staff?
      schools_for_user = School.all.reorder(:name)
    else
      schools_for_user = School.with_role(:teacher, current_staff).reorder(:name)
    end

    if schools_for_user.empty?
      flash[:error] = ('You are not a teacher at any schools!'
                       + 'You must be a teacher to access this page.')
      redirect_to staff_root_path

    else
      @schools = schools_for_user.collect do |school|
        classes = school.school_classes
        record = {id: school.id, name: school.name, admins: school.school_admins, classes: classes }
        if not current_staff.super_staff?
          record[:classes] = classes.select { |c| current_staff.has_role? :teacher, c}
        end
        record[:classes] = record[:classes].select { |c| not c.module_pages.empty? }
        record
      end #end collect
      @schools = @schools.select {|s| not s[:classes].empty? }
    end # end else
  end

  def edit_class
  end

  def check_progress
  end


end
