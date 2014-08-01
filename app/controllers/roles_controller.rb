class RolesController < ApplicationController
  respond_to :json
  js false

  def get_resources
    respond_with case params[:role_name]
                   when 'teacher'
                     School.accessible_by(current_ability, :add_teacher).
                         pluck(:id, :name).
                         map { |x| {id: "school/#{x[0]}", name: x[1]} }
                   when 'school_admin'
                     School.accessible_by(current_ability, :add_school_admin).
                         pluck(:id, :name).
                         map { |x| {id: "school/#{x[0]}", name: x[1]} }
                   when 'teacher_class'
                       SchoolClass.accessible_by(current_ability, :add_class_teacher).
                           pluck(:id, :name).
                           map { |x| {id: "school_class/#{x[0]}", name: x[1]} }
                   when 'curriculum_designer'
                       CurriculumPage.accessible_by(current_ability, :add_designer).
                           pluck(:id, :title).
                           map { |x| {id: "curriculum/#{x[0]}", name: x[1]} }
                   else
                     []
                 end
  end

  def get_roles
    resource = case params[:resource_name]
                 when 'school'
                   School.find(params[:resource_id])
                 when 'school_class'
                   SchoolClass.find(params[:resource_id])
                 when 'curriculum'
                   CurriculumPage.find(params[:resource_id])
                 else
                   nil
               end
    role_name = params[:role_name]
    role_name = 'teacher' if role_name == 'teacher_class'
    if Role.basic_role_strs.include?(role_name) && resource
      role = Role.find_or_create_by!(name: role_name, resource_type: resource.class.to_s, resource_id: resource.id)
      result = {id: role.id, name: role.to_label}
      respond_with result
    else
      head :bad_request
    end
  end
end
