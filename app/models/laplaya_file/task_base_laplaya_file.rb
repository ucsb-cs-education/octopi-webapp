class TaskBaseLaplayaFile < LaplayaFile
  belongs_to :laplaya_task, foreign_key: :task_id
  alias_attribute :parent, :laplaya_task
  include Curriculumify

  def self.new_base_file(laplaya_task)
    return self.create!(file_name: 'New Project', laplaya_task: laplaya_task)
  end

end