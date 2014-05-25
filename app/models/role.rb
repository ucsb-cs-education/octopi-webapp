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

  def self.main_roles
    [:super_user, :teacher, :school_admin, :curriculum_designer]
  end
end
