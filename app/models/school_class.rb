class SchoolClass < ActiveRecord::Base
  resourcify
  has_and_belongs_to_many :students, join_table: :school_classes_students, before_add: :verify_student
  has_and_belongs_to_many :module_pages, join_table: :module_pages_school_classes
  belongs_to :school
  validates :school, presence: true
  validates :name, presence: true, length: {maximum: 100}, uniqueness: {scope: :school}
  include SchoolClassesHelper

  def teachers
    Staff.with_role(:teacher, self)
  end

  def to_s
    self.name
  end


  def activity_progress_graph_array_for(activity, test_student = nil)
    @students = students.not_teststudents
    if test_student!=false
      @students = @students << test_student
    end


    @activity_page = ActivityPage.includes(:tasks).find(activity)
    @unlocks = Unlock.where(student: @students, school_class: self, unlockable_type: "Task", unlockable_id: @activity_page.tasks.pluck(:id))
    @responses = TaskResponse.where(student: @students, school_class: self)

    [{name: "Completed", data: @activity_page.tasks.student_visible.map { |task| {((@activity_page.tasks.where(title: task.title).count>1) ?
        task.title+"("+task.id.to_s+")" : task.title) => @responses.where(task: task, completed: true).count} }.reduce({}, :merge)},
     {name: "In progress", data: @activity_page.tasks.student_visible.map { |task| {((@activity_page.tasks.where(title: task.title).count>1) ?
         task.title+"("+task.id.to_s+")" : task.title) => @responses.where(task: task, completed: false).count} }.reduce({}, :merge)},
     {name: "Not begun", data: @activity_page.tasks.student_visible.map { |task| {((@activity_page.tasks.where(title: task.title).count>1) ?
         task.title+"("+task.id.to_s+")" : task.title) => (@unlocks.where(unlockable: task).count-@responses.where(task: task, completed: true).count-@responses.where(task: task, completed: false).count)} }.reduce({}, :merge)}]
  end

  def student_progress_graph_array_for(student)
    @tasks = Task.student_visible.where(activity_page: (ActivityPage.where(module_page: self.module_pages)))
    @unlock_count = Unlock.where(student: student, school_class: self, unlockable_type: "Task", unlockable_id: @tasks.pluck(:id)).count

    number_of_tasks_completed = TaskResponse.where(student: student, school_class: self).where(completed: true).count
    number_of_tasks_in_progress = TaskResponse.where(student: student, school_class: self).where(completed: false).count
    number_of_tasks_not_begun = @unlock_count - number_of_tasks_completed - number_of_tasks_in_progress
    number_of_locked_tasks = @tasks.count - @unlock_count

    {"Completed tasks" => number_of_tasks_completed,
     "In progress tasks" => number_of_tasks_in_progress,
     "Tasks not begun" => number_of_tasks_not_begun,
     "Locked tasks" => number_of_locked_tasks}
  end

  private
  def verify_student student
    self.errors.add(:students, 'cannot contain a student from a different school')
    raise ActiveRecord::RecordInvalid.new(self) if student.school_id != self.school_id
  end

end
