module SchoolClassesHelper

  def average_task_completion
    @responses.count/(@tasks.count * @school_class.students.count).to_f
  end

  def average_task_unlock
    @unlocks.count/( @tasks.count * @school_class.students.count).to_f
  end

end
