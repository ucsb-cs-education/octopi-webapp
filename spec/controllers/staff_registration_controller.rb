require 'spec_helper'

describe Staff::RegistrationsController, type: :controller do

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:staff]
  end

  describe 'edit' do

    before(:each) do
      @staff =  FactoryGirl.create(:staff)
      sign_in @staff
    end


    describe 'Success' do

      it 'should change the staff\'s last name' do
        subject.current_staff.should_not be_nil
        @attr = { :last_name => 'TestLastName', :current_password => @staff.password }
        put :update, :id => subject.current_staff, :staff => @attr
        expect(subject.current_staff.reload.last_name).to eq(@attr[:last_name])
        response.should redirect_to(root_path)
      end

    end

    describe 'using forbidden attributes' do
      before do
        subject.current_staff.should_not be_nil
        @attr = { :first_name => 'TestFirstName', :current_password => @staff.password, :unconfirmed_email => "thisisatest@example.com" }
        put :update, :id => subject.current_staff, :staff => @attr
      end
      it 'should update the name' do
        expect(subject.current_staff.reload.first_name).to eq(@attr[:first_name])
      end
      it 'should not change the forbidden attributes' do
        expect(subject.current_staff.reload.unconfirmed_email).to be_nil
      end
      specify{ response.should redirect_to(root_path)}
    end
  end
end