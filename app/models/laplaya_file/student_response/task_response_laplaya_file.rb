class StudentResponse::TaskResponseLaplayaFile < StudentResponse::StudentResponseLaplayaFile
  belongs_to :laplaya_task_response, foreign_key: :parent_id
  after_update :trigger_analysis

  def trigger_analysis
    if project_changed?
      Resque.enqueue_to('normal', 'process_laplaya_file',
                        {
                            processor: laplaya_task_response.task.laplaya_analysis_file.data,
                            project: project
                        }.to_json)
    end
  end

end