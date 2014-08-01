class Staff < User

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable
  # ,:timeoutable # disabled until we test and figure out a way to keep users logged in while in Snap

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}, length: {maximum: 254} #Max possible email length
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }


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

  def super_staff?
    has_role? :super_staff, :any
  end

  def super_staff
    super_staff?
  end

  def super_staff=(bool)
    if bool == true || bool == '1'
      add_role :super_staff unless super_staff?
    else
      remove_role :super_staff if super_staff?
    end
  end

  def basic_roles
    roles.where(name: Role.basic_role_syms)
  end

  def basic_roles=(new_roles)
    new_roles = Role.array_to_roles(new_roles).
        select { |x| Role.basic_role_strs.include?(x.name) && x.resource.present? }
    if self.roles.empty?
      self.roles << new_roles
    else
      self.roles = (self.roles - basic_roles) + new_roles
    end
  end

  def name
    first_name + ' ' + last_name
  end

  def self.authenticate(email, password)
    user = Staff.find_for_authentication(:email => email)
    user.valid_password?(password) ? user : nil
  end


  def self.role_adapter
    self.superclass.role_adapter
  end
end