class TaskBaseLaplayaFile < LaplayaFile
  belongs_to :laplaya_task, foreign_key: :task_id
  alias_attribute :parent, :laplaya_task
  include Curriculumify

  def clone(other_task)
    update_attributes!(file_name: other_task.file_name,
                       project: other_task.project,
                       media: other_task.media,
                       thumbnail: other_task.thumbnail,
                       note: other_task.note
    )
  end

  def self.new_base_file(laplaya_task)
    return self.create!(file_name: 'New Project', laplaya_task: laplaya_task)
  end

end