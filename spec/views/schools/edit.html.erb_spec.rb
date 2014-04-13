require 'spec_helper'

describe "schools/edit" do
  before(:each) do
    @school = assign(:school, stub_model(School,
      :name => "MyString",
      :ip_range => "MyString",
      :student_remote_access_allowed => false
    ))
  end

  it "renders the edit school form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", school_path(@school), "post" do
      assert_select "input#school_name[name=?]", "school[name]"
      assert_select "input#school_ip_range[name=?]", "school[ip_range]"
      assert_select "input#school_student_remote_access_allowed[name=?]", "school[student_remote_access_allowed]"
    end
  end
end
