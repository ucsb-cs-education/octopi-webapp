class Task < ActiveRecord::Base
  resourcify
  belongs_to :activity_page, foreign_key: :page_id
  has_many :task_dependencies, foreign_key: :dependant_id, dependent: :destroy
  has_many :prerequisites, :through => :task_dependencies, source: :prerequisite
  has_many :reverse_task_dependencies, foreign_key: :prerequisite_id, dependent: :destroy, class_name: 'TaskDependency'
  has_many :dependants, :through => :reverse_task_dependencies, source: :dependant

  has_many :activity_dependencies, foreign_key: :task_prerequisite_id, dependent: :destroy;
  has_many :activity_dependants, :through => :activity_dependencies, source: :activity_dependant
  #before_save :check_dependants


  acts_as_list scope: [:type, :page_id]
  # include CustomModelNaming
  # self.param_key = :feed
  # self.route_key = :feeds
  alias_attribute :parent, :activity_page
  include Curriculumify
  validates :title, presence: true, length: {maximum: 100}, allow_blank: false

  def depend_on(prereq)
    task_dependencies.create!(prerequisite_id: prereq.id)
  end

  def be_prereq_to(depend)
    if depend.is_a?(Task)
      reverse_task_dependencies.create!(dependant_id: depend.id)
    else
      if depend.is_a?(ActivityPage)
        activity_dependencies.create!(activity_dependant_id: depend.id)
      end
    end
  end

end
