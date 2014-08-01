module SchoolClasses::SchoolClassesStudentProgressHelper

  def number_of_tasks
    @tasks.count
  end


  def number_of_tasks_in_progress
    number_unlocked - number_of_tasks_completed
  end

  def get_visibility_for_student_of(task)
    if @unlocks.find_by(unlockable: task).nil?
      :locked
    else
      @responses.find_by(task: task, completed: true).nil? ? :visible : :completed
    end
  end
end