class Task < ActiveRecord::Base
  resourcify
  belongs_to :activity_page, foreign_key: :page_id
  has_many :task_dependencies, foreign_key: :dependant_id, dependent: :destroy
  has_many :prerequisites, :through => :task_dependencies, source: :prerequisite
  has_many :reverse_task_dependencies, foreign_key: :prerequisite_id, dependent: :destroy, class_name: 'TaskDependency'
  has_many :dependants, :through => :reverse_task_dependencies, source: :dependant

  has_many :activity_dependencies, foreign_key: :task_prerequisite_id, dependent: :destroy
  has_many :activity_dependants, :through => :activity_dependencies, source: :activity_dependant
  has_many :unlocks, as: :unlockable
  has_many :task_responses
  has_many :task_response_feedbacks
  #before_save :check_dependants
  has_paper_trail :on=> [:update, :destroy]
  scope :provide_feedback, -> {where(give_feedback: true)}

  acts_as_list scope: [:page_id]
  # include CustomModelNaming
  # self.param_key = :feed
  # self.route_key = :feeds
  alias_attribute :parent, :activity_page
  include Curriculumify
  validates :title, presence: true, length: {maximum: 100}, allow_blank: false

  def depend_on(prereq)
    task_dependencies.create!(prerequisite: prereq)
  end

  def depends_on?(prereq)
    self.prerequisites.include?(prereq)
  end

  def delete_all_responses!
    Task.transaction do
      if Unlock.where(unlockable: self, hidden: true).update_all(hidden: false) && TaskResponse.destroy_all(task: self)
        true
      else
        raise (ActiveRecord::RecordNotDestroyed)
      end
    end
  end

  def find_unlock_for(student, school_class)
    unlock = Unlock.find_for(student, school_class, self)
    if unlock.nil? && prerequisites.empty?
      unlock = Unlock.create(student: student, school_class: school_class, unlockable: self)
    end
    unlock
  end

end
