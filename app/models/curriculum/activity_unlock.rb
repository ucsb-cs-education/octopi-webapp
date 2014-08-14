class ActivityUnlock < ActiveRecord::Base
  belongs_to :school_class, foreign_key: :school_class_id
  belongs_to :student, foreign_key: :student_id
  belongs_to :activity_page
  scope :unlocked, -> { where(unlocked: true) }

  scope :where_student_class_activity, ->(student, school_class, activity) \
    { where(student: student, school_class: school_class, activity_page: activity) }

  def self.find_for(student, school_class, activity)
    result = where_student_class_activity(student, school_class, activity)
    unless activity.respond_to? :count
      result = result.take
    end
    result
  end

end