require 'spec_helper'

#module for helping controller specs
module ValidStaffHelper
  def signed_in_as_a_valid_staff
    @staff ||= FactoryGirl.create :staff
    sign_in @staff # method from devise:TestHelpers
  end
end

# module for helping request specs
module ValidStaffRequestHelper

  # for use in request specs
  def sign_in_as_a_valid_staff
    @staff ||= FactoryGirl.create :staff
    post_via_redirect staff_session_path, 'staff[email]' => @staff.email, 'staff[password]' => @staff.password
  end
end

#  module for helping feature specs
module ValidStaffFeatureHelper

  # for use in feature specs
  def sign_in_as_a_valid_staff
    staff ||= FactoryGirl.create :staff
    sign_in_as_staff(staff)
  end

  def sign_in_as_staff(staff)
    visit new_staff_session_path
    fill_in 'Email',    with: staff.email
    fill_in 'Password', with: staff.password
    click_button 'Sign in'
  end

end

RSpec.configure do |config|
  config.include ValidStaffHelper, :type => :controller
  config.include ValidStaffRequestHelper, :type => :request
  config.include ValidStaffFeatureHelper, :type => :feature
end