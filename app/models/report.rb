class Report < ActiveRecord::Base
  has_attached_file :code
  has_and_belongs_to_many :students, join_table: 'reports_students'
  has_and_belongs_to_many :tasks


  validates :name, presence: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 100 }
  validates_uniqueness_of :name
  validates :code, :attachment_presence => true
  validates_attachment_content_type :code, :content_type => ["application/javascript"]
end
