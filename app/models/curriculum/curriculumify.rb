module Curriculumify
  def self.included(base)
    base.after_create { update_curriculum_id; save }
    base.before_validation :update_curriculum_id, unless: :new_record?
    base.validates :parent, presence: true, unless: :curriculum_page?
    base.validates :curriculum_id, presence: true, unless: :new_record?
    base.validate :curriculum_id_validator, unless: :new_record?
    base.validate :title, presence: true, if: :has_title?

  end

  private
  def has_title?
    (type =~ /((Task|Project|Sandbox)Base|TaskCompleted)LaplayaFile/).nil?
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

  protected
  def difference_between_arrays(array1, array2)
    difference = array1.dup
    array2.each do |element|
      index = difference.index(element)
      if index
        difference.delete_at(index)
      end
    end
    difference
  end

  def same_elements?(array1, array2)
    extra_items = difference_between_arrays(array1, array2)
    missing_items = difference_between_arrays(array2, array1)
    extra_items.empty? & missing_items.empty?
  end
end
