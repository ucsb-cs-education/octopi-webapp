require 'spec_helper'

describe Staff::RegistrationsController, type: :controller do

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:staff]
  end

end