require 'rails_helper'

RSpec.describe TeacherPortalController, :type => :controller do

  describe "GET index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET demo" do
    it "returns http success" do
      get :demo
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET edit_class" do
    it "returns http success" do
      get :edit_class
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET check_progress" do
    it "returns http success" do
      get :check_progress
      expect(response).to have_http_status(:success)
    end
  end

end
