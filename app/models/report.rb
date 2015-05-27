class Report < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 100 }
  validates :code, presence: true
  validates_uniqueness_of :name

  has_and_belongs_to_many :students, join_table: 'reports_students'
  has_and_belongs_to_many :tasks
end
