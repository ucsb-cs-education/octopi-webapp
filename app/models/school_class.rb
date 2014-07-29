class SchoolClass < ActiveRecord::Base
  resourcify
  has_and_belongs_to_many :students, join_table: :school_classes_students, before_add: :verify_student
  has_and_belongs_to_many :module_pages, join_table: :module_pages_school_classes
  belongs_to :school
  validates :school, presence: true
  validates :name, presence: true, length: { maximum: 100 }, uniqueness: { scope: :school }

  def teachers
    Staff.with_role(:teacher, self)
  end

  def to_s
    self.name
  end

  def activity_progress_graph_array_for(activity)
    @activity_page = ActivityPage.find(activity)
    @tasks= @activity_page.tasks
    @unlocks = Unlock.where(student: students, school_class: self, unlockable_type: "Task", unlockable_id: @tasks.pluck(:id))
    @responses = TaskResponse.where(student: students, school_class: self)

    
    [{name: "Completed by", data: @tasks.map { |task| {task.title => @responses.where(task: task, completed: true).count} }.reduce({}, :merge)},
     {name: "Unlocked by", data: @tasks.map { |task| {task.title => (@unlocks.where(unlockable: task).count-@responses.where(task: task, completed: true).count)} }.reduce({}, :merge)}]
  end

  private
    def verify_student student
      self.errors.add(:students, 'cannot contain a student from a different school')
      raise ActiveRecord::RecordInvalid.new(self) if student.school_id != self.school_id
    end

end
