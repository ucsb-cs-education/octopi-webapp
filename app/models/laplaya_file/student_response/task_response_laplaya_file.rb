class StudentResponse::TaskResponseLaplayaFile < StudentResponse::StudentResponseLaplayaFile
  belongs_to :laplaya_task_response, foreign_key: :parent_id
  after_update :trigger_analysis

  def trigger_analysis(force = false)
    if project_changed? || force
      Resque.enqueue(ProcessLaplayaFileById,
                     id, laplaya_task_response.task.laplaya_analysis_file.id, parent_id)
    end
  end

end