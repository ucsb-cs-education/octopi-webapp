class School < ActiveRecord::Base
  resourcify
  has_many :students, dependent: :destroy
  has_many :school_classes, dependent: :destroy
  has_and_belongs_to_many :curriculum_pages, join_table: :curriculum_pages_schools
  validates :name, presence: true, length: { maximum: 100 }, uniqueness: true
  auto_strip_attributes :ip_range, :nullify => false
  ip_range_regex = /\A\z/ #Figure out IP_Range later. Just require it to be empty right now
  # \A and \z are like ^ and $, except that they match the start and end of the ENTIRE string, including newlines
  #This regex sill be hard, because we need to figure out how to
  validates :ip_range, :format => {:with => ip_range_regex}



  def teachers
    Staff.with_role(:teacher, self)
  end

  def school_admins
    Staff.with_role(:school_admin, self)
  end

  def users(pluck=nil)
    if pluck
      Staff.pluck(*pluck).with_any_role({name: :teacher, resource: self}, {name: :school_admin, resource: self})
    end
    Staff.with_any_role({name: :teacher, resource: self}, {name: :school_admin, resource: self})
  end

  def has_active_classes?
    (self.school_classes.select { |sc| sc.has_students? }).length > 0
  end

  def active_classes
    self.school_classes.select { |sc| sc.has_students? }
  end

  def to_s
    self.name
  end
  def self.options_for_select
    order('LOWER(name)').map { |e| [e.name, e.id] }
  end

end
