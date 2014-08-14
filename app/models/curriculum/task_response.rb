class TaskResponse < ActiveRecord::Base
  belongs_to :school_class
  belongs_to :student
  belongs_to :task
  has_many :task_response_feedbacks, dependent: :destroy
  before_save :unlock_dependencies, :if => Proc.new { self.completed == true }
  scope :completed, -> { where(completed: true) }
  scope :unlocked, -> { where(unlocked: true) }

  def unlock_dependencies(force = false)
    if (self.completed_changed? && self.completed == true) || force
      self.hidden = true if task.is_a?(AssessmentTask)
      task.activity_dependants.each do |activity|
        unlock = activity.find_unlock_for(student, school_class)
        if check_prereqs(activity) && !unlock.unlocked
          unlock.update(unlocked: true)
        end
      end
      task.dependants.each do |dependant_task|
        if check_prereqs(dependant_task) && dependant_task.get_visibility_status_for(student, school_class) == :locked
          response = TaskResponse.find_by(student: student, school_class: school_class, task: dependant_task)
          if response.nil?
            if dependant_task.is_a?(LaplayaTask)
              LaplayaTaskResponse.create(student: student, school_class: school_class, task: dependant_task, unlocked: true)
            elsif dependant_task.is_a?(AssessmentTask)
              AssessmentTaskResponse.create(student: student, school_class: school_class, task: dependant_task, unlocked: true)
            else
              TaskResponse.create(student: student, school_class: school_class, task: dependant_task, unlocked: true)
            end
          else
            response.update(unlocked: true)
          end
        end
      end
    end
  end

  def check_prereqs(model)
    model.prerequisites.each { |y|
      unless y==self.task
        prereq_response = TaskResponse.find_by(student: student, school_class: school_class, task: y)

        if prereq_response.nil? || !prereq_response.completed
          return false
        end
      end
    }
    true
  end

end