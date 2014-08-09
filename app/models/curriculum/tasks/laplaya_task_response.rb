class LaplayaTaskResponse < TaskResponse
  has_one :student_response_task_response_laplaya_file, :class_name => '::StudentResponse::TaskResponseLaplayaFile', foreign_key: :parent_id, dependent: :destroy
  alias_attribute :laplaya_file, :student_response_task_response_laplaya_file

  def self.new_response(student, school_class, laplaya_task)
    transaction do
      response = LaplayaTaskResponse.create(
          student: student,
          school_class: school_class,
          task: laplaya_task,
          completed: false
      )
      response.build_student_response_task_response_laplaya_file.clone(laplaya_task.task_base_laplaya_file)
      response.student_response_task_response_laplaya_file.owner = student
      response.student_response_task_response_laplaya_file.save!
      response.save!
      response
    end
  end

end