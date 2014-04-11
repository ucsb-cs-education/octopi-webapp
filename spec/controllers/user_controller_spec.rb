require 'spec_helper'

describe Users::RegistrationsController do

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'edit' do

    before(:each) do
      @user =  FactoryGirl.create(:user)
      sign_in @user
    end


    describe 'Success' do

      it 'should change the user\'s last name' do
        subject.current_user.should_not be_nil
        @attr = { :last_name => 'TestLastName', :current_password => @user.password }
        put :update, :id => subject.current_user, :user => @attr
        expect(subject.current_user.reload.last_name).to eq(@attr[:last_name])
        response.should redirect_to(root_path)
      end

    end

    describe 'using forbidden attributes' do
      before do
        subject.current_user.should_not be_nil
        @attr = { :first_name => 'TestFirstName', :current_password => @user.password, :unconfirmed_email => "thisisatest@example.com" }
        put :update, :id => subject.current_user, :user => @attr
      end
      it 'should update the name' do
        expect(subject.current_user.reload.first_name).to eq(@attr[:first_name])
      end
      it 'should not change the forbidden attributes' do
        expect(subject.current_user.reload.unconfirmed_email).to be_nil
      end
      specify{ response.should redirect_to(root_path)}
    end
  end
end