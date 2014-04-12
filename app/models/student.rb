class Student < ActiveRecord::Base
  belongs_to :school
  has_and_belongs_to_many :school_classes
  validates :name, presence: true, length: { maximum: 50 } , :uniqueness => {:scope => :school_id}


  has_secure_password

end
