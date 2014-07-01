require 'spec_helper'
include Devise::TestHelpers

describe 'Staff pages', type: :feature do

  subject { page }

  describe 'new staff registration page' do
    before { visit new_staff_registration_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe 'new staff registration' do

    before { visit new_staff_registration_path }

    let(:submit) { 'Sign up' }

    describe 'with invalid information' do
      it 'should not create a staff' do
        expect { click_button submit }.not_to change(Staff, :count)
      end

      describe 'after submission' do
        before { click_button submit }

        it { should have_title('Sign up') }
        it { should have_error_message('Please review the problems below:') }
        it { should have_content('can\'t be blank') }
      end
    end

    describe 'with valid information' do
      before do
        fill_in 'First name', with: 'Example'
        fill_in 'Last name', with: 'Staff'
        fill_in 'Email', with: 'staff@example.com'
        fill_in 'Password', with: 'foobarbaz'
        fill_in 'Password confirmation', with: 'foobarbaz'
      end

      it 'should create a staff' do
        expect { click_button submit }.to change(Staff, :count).by(1)
      end

      describe 'after saving the staff' do
        before { click_button submit }
        let(:staff) { Staff.find_by(email: 'staff@example.com') }

        it { should have_title(full_title('Sign in')) }
        it { should have_success_message('A message with a confirmation link has been sent to your email address. Please open the link to activate your account.') }
        it 'the staff should be valid but unconfirmed' do
          expect(staff.confirmed?).to be false
          expect(staff.valid?).to be true
        end

        describe 'signing in' do
          before do
            staff.password = 'foobarbaz'
            sign_in_as_staff staff
          end
          specify { expect(Staff.count).to eq(1) }
          it { should have_error_message('You have to confirm your account before continuing.') }
        end

      end
    end
  end
end

