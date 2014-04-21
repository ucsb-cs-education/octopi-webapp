require 'spec_helper'

describe SchoolClassesController do
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @school_class =  FactoryGirl.create(:school_class)
    @user = FactoryGirl.create(:user, school_class: @school_class)
    sign_in @user
  end


  describe "GET show" do
    it "assigns the requested school class as @school_class" do
      school_class = School_class.create! valid_attributes
      get :show, {:id => school_class.to_param}, valid_session
      assigns(:school_class).should eq(school_class)
    end
  end
end
