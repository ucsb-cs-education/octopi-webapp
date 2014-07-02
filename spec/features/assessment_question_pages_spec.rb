require 'spec_helper'

describe "Assessment question page" do

  subject{ page }

  let(:assessment_question){ FactoryGirl.create(:assessment_question)}
  let(:staff) { FactoryGirl.create(:staff, :super_staff) }

  before do
    capy_sign_in staff
    visit assessment_question_path(assessment_question)
  end

  describe "valid page" do
    it{should have_content("Add New Answer Choice")}
    it{should have_content("One Correct")}
    it{should have_content("Multiple Correct")}
  end

  describe "one answer" do
    it{should have_selector("div.answer",:count => 1)}
    describe "add answer", js: true do
      before do
        visit assessment_question_path(assessment_question)
        click_on("addAns")
      end
      it{should have_selector("div.answer",:count => 2)}
    end
  end
end