class User < ActiveRecord::Base
  rolify
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  alias_attribute :password_digest, :encrypted_password

  alias_method :rolify_add_role, :add_role

  def add_role(*options)
    self.becomes(User).rolify_add_role(*options)
  end

  def name
    "#{first_name} #{last_name}"
  end

end
