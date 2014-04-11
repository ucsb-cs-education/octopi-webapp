class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super # creates the @user
  end
end