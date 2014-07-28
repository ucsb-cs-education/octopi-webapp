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
    if object.type == 'StudentResponse::TaskResponseLaplayaFile'
      object = object.becomes(StudentResponse::TaskResponseLaplayaFile)
      object.laplaya_task_response.task.student_body
    end
  end

  def analysis_processor
    if object.type == 'StudentResponse::TaskResponseLaplayaFile'
      object = object.becomes(StudentResponse::TaskResponseLaplayaFile)
      analysis_file = object.laplaya_task_response.task.laplaya_analysis_file
      if analysis_file
        analysis_file.data
      else
        nil
      end
    end
  end

  def filter(keys)
    unless object.type == 'StudentResponse::TaskResponseLaplayaFile'
      keys = keys - [:analysis_processor, :instructions]
    end
    keys
  end

end
