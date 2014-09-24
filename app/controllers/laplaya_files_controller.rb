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
    respond_to do |format|
      format.json do
        render json: @laplaya_file
      end
      format.xml do
        render text: "<snapdata>#{@laplaya_file.project}#{@laplaya_file.media}</snapdata>"
      end
    end
  end

  def update
    LaplayaFile.transaction do
      pre_success = true
      if params[:laplaya_task].nil? || params[:laplaya_file]
        pre_success = false
        params = laplaya_file_params
        if params.any?
          @laplaya_file.assign_attributes(params)
          pre_success = update_log
          unless pre_success && @laplaya_file.save
            pre_success = false
          end
        end
      end
      if pre_success && @laplaya_file.is_a?(StudentResponse::TaskResponseLaplayaFile)
        success = false
        begin
          params = task_response_feedback_params
          if params.any?
            task_response = @laplaya_file.laplaya_task_response
            task_response.task_response_feedbacks.create!(task_response_feedback_params)
            #add feedback to feedback file
            success = [true, 'laplaya_feedback_created']
            if pre_success.is_a? Array
              success[1] = "#{success[1]} & #{pre_success[1]}"
            end
          end
        rescue ActionController::ParameterMissing
          success = pre_success
        end
      else
        success = pre_success
      end
      if success === true
        head :no_content, location: laplaya_file_url(@laplaya_file)
      elsif success.is_a?(Array) && (success[0] === true)
        render text: success[1], status: 200, location: laplaya_file_url(@laplaya_file)
      else
        bad_request_with_errors @laplaya_file
      end
    end
  end


  def create
    @laplaya_file.owner = current_user
    if update_log && @laplaya_file.save
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
  def access_denied_handler(exception)
    @_elevated ||= false
    if !@_elevated && current_user && current_user.is_a?(TestStudent)
      @_elevated = true
      Ability.new(current_staff).authorize!(action_name.to_sym, @laplaya_file)
      @_current_user = current_staff
      self.send(action_name)
    else
      super(exception)
    end
  end

  def update_log
    if params[:log] && @laplaya_file.is_a?(StudentResponse::StudentResponseLaplayaFile)
      log_params = params[:log]
      if log_params[:logHash] && log_params[:data]
        old_data = log_params[:data]
        log_entry = {data: nil, log_hash: log_params[:logHash], parent_hash: log_params[:parentHash]}
        data = []
        curr = 0
        while true
          if old_data.has_key?(curr.to_s)
            data.append(old_data[curr.to_s])
          else
            break
          end
          curr+=1
        end
        log_entry[:data] = data
        @laplaya_file.log = @laplaya_file.log + [log_entry.to_json]
        @laplaya_file.save_uuid = log_entry[:log_hash]
        return [true, 'log updated']
      else
        @laplaya_file.errors.add(:log, 'an updated log requires the log data, and a log hash')
        return false
      end
    end
    return true
  end

  def signed_in_user
    authenticate_staff! unless current_staff || current_student
  end

  def current_user
    @_current_user ||= if current_staff
                         if teacher_using_test_student?
                           current_student
                         else
                           current_staff
                         end
                       else
                         current_student
                       end
    @_current_user
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
