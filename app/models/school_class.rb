class SchoolClass < ActiveRecord::Base
  has_and_belongs_to_many :students
  belongs_to :school
  validates :school, presence: true
  resourcify
end
