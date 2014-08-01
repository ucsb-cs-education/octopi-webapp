class Unlock < ActiveRecord::Base
  belongs_to :school_class, foreign_key: :school_class_id
  belongs_to :student, foreign_key: :student_id
  belongs_to :unlockable, polymorphic: true

  scope :where_student_class_unlockable, ->(student, school_class, unlockable) \
    { where(student: student, school_class: school_class, unlockable: unlockable) }

  def self.find_for(student, school_class, unlockable)
    result = where_student_class_unlockable(student, school_class, unlockable)
    unless unlockable.respond_to? :count
      result = result.take
    end
    result
  end

end