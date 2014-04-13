require 'spec_helper'

describe "schools/show" do
  before(:each) do
    @school = assign(:school, stub_model(School,
      :name => "Name",
      :ip_range => "Ip Range",
      :student_remote_access_allowed => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Ip Range/)
    rendered.should match(/false/)
  end
end
