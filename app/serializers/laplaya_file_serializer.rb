class LaplayaFileSerializer < ActiveModel::Serializer
  attributes :file_id, :file_name, :public, :note, :updated_at, :project, :media, :can_update, :instructions, :analysis_processor
  # has_many :owners

  def file_id
    object.id
  end

  def can_update
    Ability.new(scope).can?(:update, object)
  end

  def instructions
    task =
        case object.type
          when 'StudentResponse::TaskResponseLaplayaFile'
            object.becomes(StudentResponse::TaskResponseLaplayaFile).laplaya_task_response.task
          when 'TaskBaseLaplayaFile'
            object.becomes(TaskBaseLaplayaFile).laplaya_task
          when 'TaskCompletedLaplayaFile'
            object.becomes(TaskCompletedLaplayaFile).laplaya_task
          else
            nil
        end
    task.student_body
  end

  def analysis_processor
    task =
        case object.type
          when 'StudentResponse::TaskResponseLaplayaFile'
            object.becomes(StudentResponse::TaskResponseLaplayaFile).laplaya_task_response.task
          when 'TaskBaseLaplayaFile'
            object.becomes(TaskBaseLaplayaFile).laplaya_task
          when 'TaskCompletedLaplayaFile'
            object.becomes(TaskCompletedLaplayaFile).laplaya_task
          else
            nil
        end
    result = task.laplaya_analysis_file
    result = result.force_encoding('UTF-8') unless result.nil?
    result
  end

  def filter(keys)
    unless object.type == 'StudentResponse::TaskResponseLaplayaFile' ||
        object.type == 'TaskBaseLaplayaFile' ||
        object.type == 'TaskCompletedLaplayaFile'
      keys = keys - [:analysis_processor, :instructions]
    end
    keys
  end

end
