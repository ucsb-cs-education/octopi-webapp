class Task < ActiveRecord::Base
  resourcify
  belongs_to :activity_page, foreign_key: :page_id
  has_many :task_dependencies, foreign_key: :dependant_id, dependent: :destroy
  has_many :prerequisites, :through => :task_dependencies, source: :prerequisite
  has_many :reverse_task_dependencies, foreign_key: :prerequisite_id, dependent: :destroy, class_name: 'TaskDependency'
  has_many :dependants, :through => :reverse_task_dependencies, source: :dependant

  acts_as_list scope: [:type, :page_id]
  # include CustomModelNaming
  # self.param_key = :feed
  # self.route_key = :feeds
  alias_attribute :parent, :activity_page
  include Curriculumify
  validates :title, presence: true, length: {maximum: 100}, allow_blank: false

  def depend_on(prereq_id)
    task_dependencies.create!(prerequisite_id: prereq_id)
  end

  def be_prereq_to(depend_id)
    reverse_task_dependencies.create!(dependant_id: depend_id)
  end

  def complete_me(params)
    unlock = Unlock.find_by(student_id: params['student_id'], school_class_id: params['school_class_id'],
                            unlockable_type: "Task", unlockable_id: id)
    if unlock!=nil
      unlock.completed = true
      unlock.save
    end

  end

end
