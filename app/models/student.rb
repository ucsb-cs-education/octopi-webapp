class Student < ActiveRecord::Base
  # Note (jhenkens) : I am not sure that Student needs to be resourced at all - I do not see a scenario in which a User
  # needs to have a specific role over a User in the current scenario.
  #resourcify :roles
  rolify
  belongs_to :school, counter_cache: true
  has_and_belongs_to_many :school_classes, after_add: :verify_classes
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :login_name, presence: true, length: { maximum: 50 } , :uniqueness => {:scope => :school_id, :case_sensitive => false}
  validates :school, presence: true
  before_save { login_name.downcase! }
  before_create :create_remember_token

  has_secure_password

  def Student.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def Student.create_remember_hash(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def name
    return "#{first_name} #{last_name}"
  end

  private
    def create_remember_token
      self.remember_token = Student.create_remember_hash(Student.new_remember_token)
    end

    def verify_classes school_class
      raise ActiveRecord::RecordInvalid.new(self) if school_class.school_id != self.school_id
    end

end
