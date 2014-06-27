module Curriculumify
  def self.included(base)
    base.after_create { update_curriculum_id; save }
    base.before_validation :update_curriculum_id, unless: :new_record?
    base.validates :parent, presence: true, unless: :curriculum_page?
    base.validates :curriculum_id, presence: true, unless: :new_record?
    base.validate :curriculum_id_validator, unless: :new_record?

  end

  def curriculum_page?
    type == 'CurriculumPage'
  end

  def update_curriculum_id
    if curriculum_page?
      self.curriculum_id = id
    else
      self.curriculum_id = parent.curriculum_id
    end
  end

  def curriculum_id_validator
    if curriculum_page?
      unless id == curriculum_id
        errors.add(:curriculum_id, "must be equal to id")
      end
    else
      unless parent.curriculum_id == curriculum_id
        errors.add(:curriculum_id, "must be equal to parent curriculum_id")
      end
    end
  end
end