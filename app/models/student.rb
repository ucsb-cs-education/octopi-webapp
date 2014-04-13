class Student < ActiveRecord::Base
  belongs_to :school
  has_and_belongs_to_many :school_classes
  validates :name, presence: true, length: { maximum: 50 } , :uniqueness => {:scope => :school_id}
  validates :school, presence: true

  resourcify

  has_secure_password

  def Student.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def Student.hash(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  private
  def create_remember_token
    self.remember_token = Student.hash(User.new_remember_token)
  end

end
