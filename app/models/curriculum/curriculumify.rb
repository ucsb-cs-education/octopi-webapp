module Curriculumify
  def self.included(base)
    base.after_create { update_curriculum_id; save }
    base.before_validation :update_curriculum_id, unless: :new_record?
    base.validates :parent, presence: true, unless: :curriculum_page?
    base.validates :curriculum_id, presence: true, unless: :new_record?
    base.validate :curriculum_id_validator, unless: :new_record?
    base.validate :title, presence: true, if: :has_title?
    base.before_save :set_visibility_statuses, if: :has_visibility_status?
    base.after_initialize :initialize_visible_to, if: :has_visibility_status?
    attr_accessor :visible_to
    if is_page_or_task?(base.to_s)
      base.scope :student_visible, -> { base.where(visible_to_students: true)}
      base.scope :teacher_visible, -> { base.where(visible_to_teachers: true)}
      base.scope :only_teacher_visible, -> { base.where(visible_to_teachers: true, visible_to_students: false)}
    end

  end

  private
  def self.is_page_or_task?(type)
    type == 'Page' || type == 'Task'
  end

  def has_visibility_status?(type = self.type)
    (type =~ /((Task|Project|Sandbox)Base|TaskCompleted)LaplayaFile|CurriculumPage/).nil?
  end

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
        errors.add(:curriculum_id, 'must be equal to id')
      end
    else
      unless parent.curriculum_id == curriculum_id
        errors.add(:curriculum_id, 'must be equal to parent curriculum_id')
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
private
  def initialize_visible_to
    if visible_to_teachers
      if visible_to_students
        self.visible_to = :all
      else
        self.visible_to = :teachers
      end
    else
      self.visible_to = :none
    end
  end

  private
  def set_visibility_statuses
    visible_to = self.visible_to.to_sym
    if [:all, :teachers, :none].include? visible_to
      unless visible_to_teachers_changed?
        new_val = (visible_to == :all || visible_to == :teachers)
        if visible_to_teachers != new_val
          self.visible_to_teachers = new_val
        end
      end
      unless visible_to_students_changed?
        new_val = (visible_to == :all)
        if visible_to_students != new_val
          self.visible_to_students = new_val
        end
      end
      true
    else
      self.errors.add :visible_to, 'must be either :all, :teachers, or :none'
      false
    end
  end

  def update_with_children_helper(klass, params, ids)
    begin
      transaction do
        child_ids = children.pluck(:id).map { |x| x.to_s }
        unless same_elements?(child_ids, ids)
          self.errors.add :children, 'update_children_order ids must match children ids'
          raise ArgumentError
        else
          if child_ids != ids
            children = {}
            ids.each_with_index.map { |x, i| children[x] = {position: i+1} }
            klass.update(children.keys, children.values)
          end
          update_attributes!(params)
        end
      end
      true
    rescue ArgumentError, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
      false
    end
  end
end
