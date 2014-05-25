class SchoolClass < ActiveRecord::Base
  resourcify
  has_and_belongs_to_many :students, before_add: :verify_student
  belongs_to :school
  validates :school, presence: true
  validates :name, presence: true, length: { maximum: 100 }, uniqueness: true

  def teachers
    Staff.with_role(:teacher, self)
  end

  def to_s
    self.name
  end

  private
    def verify_student student
      raise ActiveRecord::RecordInvalid.new(self) if student.school_id != self.school_id
    end

end
