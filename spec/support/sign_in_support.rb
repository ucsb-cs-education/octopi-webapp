require 'spec_helper'

#module for helping controller specs
module SignInHelpers
  def sign_in_as(user)
    if user.class == Student
      sign_in_as_student(user)
    elsif user.class == Staff
      sign_in_as_staff(user)
    end
  end

  def sign_in_as_staff(staff)
    @staff = staff
    sign_in_as_a_valid_staff
  end

  def sign_in_as_student(student)
    @student = student
    sign_in_as_a_valid_student
  end

  def sign_in_as_a_valid_staff
    @staff ||= FactoryGirl.create :staff
    sign_in_as_a_valid_staff_helper
  end

  def sign_in_as_a_valid_student
    @student ||= FactoryGirl.create :student
    sign_in_as_a_valid_student_helper
  end
end

module ValidUserControllerHelper
  private
  def sign_in_as_a_valid_staff_helper
    sign_in @staff # method from devise:TestHelpers
  end

  def sign_in_as_a_valid_student_helper
    # Sign in when not using Capybara.
    remember_token = Student.new_remember_token
    session[:student_remember_token] = remember_token
    @student.update_attribute(:remember_token, Student.create_remember_hash(remember_token))
  end
end

# module for helping request specs
module ValidUserRequestHelper

  # for use in request specs
  def sign_in_as_a_valid_staff_helper
    post_via_redirect staff_session_path, 'staff[email]' => @staff.email, 'staff[password]' => @staff.password
  end

  def sign_in_as_a_valid_student_helper
    raise NotImplementedError
  end

end

#  module for helping feature specs
module ValidUserFeatureHelper

  # for use in feature specs
  def sign_in_as_a_valid_staff_helper
    visit new_staff_session_path
    fill_in 'Email',    with: @staff.email
    fill_in 'Password', with: @staff.password
    click_button 'Sign in'
  end

  def sign_in_as_a_valid_student_helper
    visit student_portal_signin_path
    select user.school.name, from: 'School'
    select user.login_name, from: 'Login Name'
    fill_in "Password", with: user.password
    click_button "Sign in"
  end

end

RSpec.configure do |config|
  config.include ValidUserControllerHelper, type: :controller
  config.include ValidUserRequestHelper, type: :request
  config.include ValidUserFeatureHelper, type: :feature
  config.include SignInHelpers, type: :controller
  config.include SignInHelpers, type: :request
  config.include SignInHelpers, type: :feature
end