class Staff < User

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable, :confirmable

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }, length: {maximum: 254 } #Max possible email length
  # scope :unconfirmed, where(confirmed_at: nil)


  # Taken from https://github.com/plataformatec/devise/wiki/How-To%3a-Require-admin-to-activate-account-before-sign_in
  # Uncomment here and change initial migration when ready to test
  #def active_for_authentication?
  #  super && approved?
  #end
  #
  #def inactive_message
  #  if !approved?
  #    :not_approved
  #  else
  #    super # Use whatever other message
  #  end
  #end
  #after_create :send_admin_mail
  #def send_admin_mail
  #  AdminMailer.new_user_waiting_for_approval(self).deliver
  #end


  def teacher?
    has_role? :teacher, :any
  end

  def school_admin?
    has_role? :school_admin, :any
  end

  def super_user?
    has_role? :super_user, :any
  end

  def name
    first_name + ' ' + last_name
  end

  def self.authenticate(email, password)
    user = User.find_for_authentication(:email => email)
    user.valid_password?(password) ? user : nil
  end

  def self.role_adapter
    self.superclass.role_adapter
  end
end