class School < ActiveRecord::Base
  has_many :students, dependent: :destroy
  has_many :teachers, :class_name => "User" #, -> { where is_teacher: true}
  has_many :administrators, :class_name => "User" #, -> { where is_teacher: true}
  resourcify
end
