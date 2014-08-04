module SchoolClassesHelper

  def average_task_completion
    @responses.where(completed: true).count/(@tasks.count * @school_class.students.count).to_f
  end

  def average_task_unlock
    @unlocks.where(unlockable_type: Task).count/( @tasks.count * @school_class.students.count).to_f
  end

end
