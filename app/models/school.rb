class School < ActiveRecord::Base
  has_many :students, dependent: :destroy
  resourcify

  def teachers
    User.with_role(:teacher, self)
  end

  def school_admins
    User.with_role(:school_admin, self)
  end

end
