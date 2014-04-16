class School < ActiveRecord::Base
  has_many :students, dependent: :destroy
  validates :name, presence: true, length: { maximum: 100 }, uniqueness: true
  resourcify

  def teachers
    User.with_role(:teacher, self)
  end

  def school_admins
    User.with_role(:school_admin, self)
  end

end
