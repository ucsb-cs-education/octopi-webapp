require 'spec_helper'
include Devise::TestHelpers

describe 'User pages' do

  subject { page }

  describe 'new user registration page' do
    before { visit new_user_registration_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe 'new user registration' do

    before { visit new_user_registration_path }

    let(:submit) { 'Sign up' }

    describe 'with invalid information' do
      it 'should not create a user' do
        expect { click_button submit }.not_to change(User, :count)
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
        fill_in 'First name',             with: 'Example'
        fill_in 'Last name',             with: 'User'
        fill_in 'Email',            with: 'user@example.com'
        fill_in 'Password',         with: 'foobarbaz'
        fill_in 'Password confirmation', with: 'foobarbaz'
      end

      it 'should create a user' do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe 'after saving the user' do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_title(full_title('Home') ) }
        it { should have_warning_message('A message with a confirmation link has been sent to your email address. Please open the link to activate your account.') }
        it 'the user should be valid but unconfirmed' do
          expect(user.confirmed?).to be_false
          expect(user.valid?).to be_true
        end

        describe 'signing in' do
          before do
            user.password = 'foobarbaz'
            capy_sign_in user
          end
          specify{expect(User.count).to eq(1)}
          it { should have_error_message('You have to confirm your account before continuing.') }
        end

      end
    end
  end
  describe 'edit' do
    let(:user) { FactoryGirl.create(:user) }
    let(:submit) { 'Update' }
    before do
      capy_sign_in user
      visit edit_user_registration_path(user)
    end

    describe 'page' do
      it { should have_content('Edit User') }
      it { should have_title(full_title('Edit User')) }
      it { should have_link('Back')}
      it { should have_field('First name', with: user.first_name ) }
      it { should have_field('Last name', with: user.last_name ) }
      it { should have_field('Email', with: user.email ) }
    end

    describe 'with invalid information' do
      before { click_button submit }
      it { should have_error_message('Please review the problems below:') }
      it { should have_content('we need your current password') }
    end

    describe 'with valid information' do
      let(:new_name)  { 'New Name' }
      let(:new_email) { 'new@example.com' }
      before do
        fill_in 'First name',             with: new_name
        fill_in 'Last name',              with: new_name
        fill_in 'Email',                  with: new_email
        fill_in 'Current password',       with: user.password
        click_button submit
        user.reload.confirm!
      end

      it { should have_title(full_title('Home')) }
      it { should have_warning_message('You updated your account successfully,'+
                                           ' but we need to verify your new email'+
                                           ' address. Please check your email and'+
                                           ' click on the confirm link to finalize'+
                                           ' confirming your new email address.') }
      it { should have_link('Sign Out', href: destroy_user_session_path) }
      specify { expect(user.reload.first_name).to  eq new_name }
      specify { expect(user.reload.last_name).to  eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end
  end
end