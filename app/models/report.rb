class Report < ActiveRecord::Base
  has_and_belongs_to_many :students, join_table: 'reports_students'
  has_and_belongs_to_many :tasks
end
