class SchoolClass < ActiveRecord::Base
  resourcify
  has_and_belongs_to_many :students
  belongs_to :school
  validates :school, presence: true
  validates :name, presence: true, length: { maximum: 100 }, uniqueness: true

  def teachers
    User.with_role(:teacher, self)
  end

end
