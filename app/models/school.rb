class School < ActiveRecord::Base
  resourcify
  has_many :students, dependent: :destroy
  has_many :school_classes, dependent: :destroy
  validates :name, presence: true, length: { maximum: 100 }, uniqueness: true
  auto_strip_attributes :ip_range, :nullify => false
  ip_range_regex = /\A\z/ #Figure out IP_Range later. Just require it to be empty right now
  # \A and \z are like ^ and $, except that they match the start and end of the ENTIRE string, including newlines
  #This regex sill be hard, because we need to figure out how to
  validates :ip_range, :format => {:with => ip_range_regex}


  def teachers
    User.with_role(:teacher, self)
  end

  def school_admins
    User.with_role(:school_admin, self)
  end

end
