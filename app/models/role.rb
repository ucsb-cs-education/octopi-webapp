class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true

  scopify

  def to_label
    result = self.name
    if self.resource.present?
      result += ":{#{self.resource.to_s}}"
    elsif self.resource_type.present?
      result += ":{#{self.resource_type.to_s}}.class"
    end
    result
  end

  def self.array_to_roles(array)
    ((array.select { |x| x.present? }).
        map { |x| (x.class == Role) ? x : Role.find(x) })
  end

  def self.global_roles
    [:super_staff]
  end

  def self.basic_role_syms
    [:teacher, :school_admin, :curriculum_designer]
  end

  def self.basic_role_strs
    basic_role_syms.map { |x| x.to_s }
  end


end
