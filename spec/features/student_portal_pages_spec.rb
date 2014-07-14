require 'spec_helper'

describe "student portal", type: :feature do
  subject{page}
  let(:new_student){ FactoryGirl.create(:student)}

  shared_examples "a standard page" do
    describe "with the correct content" do
      it{should have_content("student-body")}
    end
  end

  describe "module page" do
    let(:module_page){ FactoryGirl.create(:module_page)}
    let(:thisPath){student_portal_module_path(module_page)}

    before do
      sign_in_as(new_student)
      visit(thisPath)
    end

    it_behaves_like "a standard page"
  end
end

