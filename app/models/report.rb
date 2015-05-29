class Report < ActiveRecord::Base
  has_attached_file :code
  has_and_belongs_to_many :students, join_table: 'reports_students'
  has_and_belongs_to_many :tasks
  has_many :report_module_options

  
  has_many :report_runs


  validates :name, presence: true
  validates :description, presence: true
  validates_uniqueness_of :name
  validates :code, :attachment_presence => true
  validates_attachment_content_type :code, :content_type => ["application/javascript", "text/plain"]
end
