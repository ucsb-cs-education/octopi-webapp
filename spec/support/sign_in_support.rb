require 'spec_helper'

#module for helping controller specs
module ValidStaffHelper
  def sign_in_as_a_valid_staff
    @staff ||= FactoryGirl.create :staff
    sign_in @staff # method from devise:TestHelpers
  end

  def sign_in_as_staff(staff)
    @staff = staff
    sign_in_as_a_valid_staff
  end

  def sign_in_as_a_valid_student
    @student ||= FactoryGirl.create :student
    # Sign in when not using Capybara.
    remember_token = Student.new_remember_token
    cookies[:remember_token] = remember_token
    @student.update_attribute(:remember_token, Student.create_remember_hash(remember_token))
  end

  def sign_in_as_student(student)
    @student = student
    sign_in_as_a_valid_student
  end

end

# module for helping request specs
module ValidStaffRequestHelper

  # for use in request specs
  def sign_in_as_a_valid_staff
    @staff ||= FactoryGirl.create :staff
    post_via_redirect staff_session_path, 'staff[email]' => @staff.email, 'staff[password]' => @staff.password
  end

  def sign_in_as_staff(staff)
    @staff = staff
    sign_in_as_a_valid_staff
  end

  def sign_in_as_a_valid_student
    @student ||= FactoryGirl.create :student
    # Sign in when not using Capybara.
    remember_token = Student.new_remember_token
    cookies[:remember_token] = remember_token
    @student.update_attribute(:remember_token, Student.create_remember_hash(remember_token))
  end

  def sign_in_as_student(student)
    @student = student
    sign_in_as_a_valid_student
  end
end

#  module for helping feature specs
module ValidStaffFeatureHelper

  # for use in feature specs
  def sign_in_as_a_valid_staff
    @staff ||= FactoryGirl.create :staff
    visit new_staff_session_path
    fill_in 'Email',    with: @staff.email
    fill_in 'Password', with: @staff.password
    click_button 'Sign in'
  end

  def sign_in_as_staff(staff)
    @staff = staff
    sign_in_as_a_valid_staff
  end

  def sign_in_as_a_valid_student
    @student ||= FactoryGirl.create :student
    visit signin_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
  end

  def sign_in_as_student(student)
    @student = student
    sign_in_as_a_valid_student
  end
end

RSpec.configure do |config|
  config.include ValidStaffHelper, :type => :controller
  config.include ValidStaffRequestHelper, :type => :request
  config.include ValidStaffFeatureHelper, :type => :feature
end