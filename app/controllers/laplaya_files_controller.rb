require 'student_signin_module'

class LaplayaFilesController < ApplicationController
  include StudentSigninModule
  load_and_authorize_resource :laplaya_file
  protect_from_forgery with: :null_session
  before_action :signed_in_user
  before_action :confirm_unlocked, only: [:show, :update]
  js false

  def index
    #Following line needed to prevent super_staff from crashing server during index
    @laplaya_files = LaplayaFile.where(owner: current_user) if current_user && current_user.has_role?(:super_staff)
    render json: @laplaya_files, each_serializer: LaplayaFileIndexSerializer
  end

  def show
    @laplaya_file = @laplaya_file.becomes(LaplayaFile)
    render json: @laplaya_file
  end

  def update
    params = laplaya_file_params
    if params.any? && @laplaya_file.update_attributes(params)
      head :no_content, location: laplaya_file_url(@laplaya_file)
    else
      bad_request_with_errors @laplaya_file
    end
    if @laplaya_file.is_a? StudentResponse::TaskResponseLaplayaFile
      begin
        params = task_response_feedback_params
        if params.any?
          #add feedback to feedback file
        end
      rescue ActionController::ParameterMissing
        # ignored
      end

      end
    end

    def create
      @laplaya_file.owner = current_user
      if @laplaya_file.save
        create_post_success_response(:created, laplaya_file_url(@laplaya_file), @laplaya_file.id)
      else
        bad_request_with_errors @laplaya_file
      end
    end

    def destroy
      @laplaya_file.destroy
      head :no_content
    end

    private
    def signed_in_user
      authenticate_staff! unless current_staff || current_student
    end

    def current_user
      current_staff || current_student
    end

    def laplaya_file_params
      avail_params = [:project, :media]
      if can? :create_public_laplaya_files, LaplayaFile
        avail_params << :public
      end
      params.require(:laplaya_file).permit(*avail_params)
    end

    def task_response_feedback_params
      params.require(:laplaya_task).permit(:feedback)
    end

    def confirm_unlocked
      if signed_in_student?
        case @laplaya_file.type
          when 'StudentResponse::TaskResponseLaplayaFile'
            unless @laplaya_file.laplaya_task_response.task.is_accessible?(current_student, current_school_class)
              raise CanCan::AccessDenied
            end
          when 'StudentResponse::ProjectResponseLaplayaFile',
              'StudentResponse::SandboxResponseLaplayaFile',
              'SandboxBaseLaplayaFile'
            unless current_school_class && current_school_class.module_pages.include?(@laplaya_file.module_page)
              raise CanCan::AccessDenied
            end
          else
            # type code here
        end
      end
    end

    protected
    def create_post_success_response (status, location, file_id)
      render json: {success: true, location: location, file_id: file_id}, location: location, status: status
    end

  end
