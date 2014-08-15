class Staff < User

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable
  # ,:timeoutable # disabled until we test and figure out a way to keep users logged in while in Snap

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  before_validation :assign_password
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}, length: {maximum: 254} #Max possible email length
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  has_one :test_student, foreign_key: :test_student_id
  validate :manual_invalidator
  attr_accessor :assign_a_random_password


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
  alias_method :_user_add_role, :add_role

  def assign_password
    if assign_a_random_password === true
      require 'securerandom'
      _password = SecureRandom.hex(16)
      self.password = _password
      self.password_confirmation = _password
    end
  end

  def add_role(*args)
    @super_staff = nil
    @teacher = nil
    @school_admin = nil
    @curriculum_designer = nil
    _user_add_role *args
  end

  def teacher?(allow_superstaff = false)
    if @teacher.nil?
      @teacher = has_role? :teacher, :any
    end
    @teacher || (allow_superstaff && super_staff?)
  end

  def school_admin?(allow_superstaff = false)
    if @school_admin.nil?
      @school_admin = has_role? :school_admin, :any
    end
    @school_admin || (allow_superstaff && super_staff?)
  end

  def curriculum_designer?(allow_superstaff = false)
    if @curriculum_designer.nil?
      @curriculum_designer = has_role? :curriculum_designer, :any
    end
    @curriculum_designer || (allow_superstaff && super_staff?)
  end

  def super_staff?
    if @super_staff.nil?
      @super_staff = has_role? :super_staff, :any
    end
    @super_staff
  end

  def super_staff
    super_staff?
  end

  def school_admin
    school_admin?
  end

  def teacher
    teacher?
  end

  def super_staff=(bool)
    if bool == true || bool == '1'
      add_role :super_staff unless super_staff?
    else
      remove_role :super_staff if super_staff?
    end
  end

  def basic_roles
    if new_record?
      roles.to_a.select {|role| Role.basic_role_strs.include? role.name }
    else
      roles.where(name: Role.basic_role_syms)
    end
  end

  def basic_roles=(new_roles)
    new_roles = Role.array_to_roles(new_roles).
        select { |x| Role.basic_role_strs.include?(x.name) && x.resource.present? }
    self.roles = (self.roles - basic_roles) + new_roles
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

  def manual_invalidations
    @manual_invalidations ||= []
  end

  private
  def manual_invalidator
    if self.manual_invalidations.any?
      self.manual_invalidations.each do |validation|
        if validation.is_a? Hash
          validation.each do |key, value|
            errors.add key, value
          end
        else
          raise StandardError('Invalid type in manual invalidations')
        end
      end
      false
    else
      true
    end
  end

end
