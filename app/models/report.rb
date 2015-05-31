class Report < ActiveRecord::Base
  has_attached_file :code
  has_and_belongs_to_many :students, join_table: 'reports_students'
  has_and_belongs_to_many :tasks
  has_many :report_module_options, class_name: ReportModuleOptions

  
  has_many :report_runs


  validates :name, presence: true
  validates :description, presence: true
  validates_uniqueness_of :name
  validates :code, :attachment_presence => true
  validates_attachment_content_type :code, :content_type => ["application/javascript", "text/plain"]

  def create_run
    jobs = []
    responses = TaskResponse.where({task_id: self.tasks, student_id: self.students}).pluck(:id)
    task_files = StudentResponse::TaskResponseLaplayaFile.where(parent_id: responses).pluck(:id)
    project_files = StudentResponse::ProjectResponseLaplayaFile.where(parent_id: self.report_module_options.where(include_project: true).pluck(:module_page_id)).pluck(:id)
    sandbox_files = StudentResponse::SandboxResponseLaplayaFile.where(parent_id: self.report_module_options.where(include_sandbox: true).pluck(:module_page_id)).pluck(:id)
    jobs.concat(task_files).concat(project_files).concat(sandbox_files)
    run = ReportRun.new
    self.report_runs << run
    run.save!
    self.save!
    Report.transaction do
      jobs.each do |j|
        ts = Time.now
        Report.connection.execute("INSERT INTO report_run_results  (\"created_at\", \"updated_at\", \"laplaya_file_id\", \"report_run_id\") VALUES ('#{ts}', '#{ts}', #{j}, #{run.id})")  
      end
    end

    jobs.each do |j|
      Resque.enqueue(ProcessReportRunById, run.id, self.id, j)
    end
  end
end
