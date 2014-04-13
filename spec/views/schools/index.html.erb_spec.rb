require 'spec_helper'

describe "schools/index" do
  before(:each) do
    assign(:schools, [
      stub_model(School,
        :name => "Name",
        :ip_range => "Ip Range",
        :student_remote_access_allowed => false
      ),
      stub_model(School,
        :name => "Name",
        :ip_range => "Ip Range",
        :student_remote_access_allowed => false
      )
    ])
  end

  it "renders a list of schools" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Ip Range".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
