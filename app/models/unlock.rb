class Unlock < ActiveRecord::Base
  belongs_to :school_class, foreign_key: :school_class_id
  belongs_to :student, foreign_key: :student_id
  belongs_to :unlockable, polymorphic: true

end