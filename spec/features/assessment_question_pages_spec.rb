require 'spec_helper'

describe "Assessment question page" do

  subject{ page }

  let(:assessment_question){ FactoryGirl.create(:assessment_question)}
  let(:user) { FactoryGirl.create(:staff, :super_staff) }

  before do
    sign_in_as_staff(user)
    visit assessment_question_path(assessment_question)
  end

  describe "valid page" do
    it{should have_content("Add New Answer Choice")}
    it{should have_content("One Correct")}
    it{should have_content("Multiple Correct")}
  end

  describe "answer tests" do
    it{should have_selector("div.answer",:count => 1)}
    describe "add answer", js: true do
      before do
        visit assessment_question_path(assessment_question)
        click_on("addAns")
      end
      it{should have_selector("div.answer",:count => 2)}
    end
    describe "remove answer", js: true do
      before do
        first(".deleteAnswer").click
        page.driver.browser.switch_to.alert.accept
      end
      it{should_not have_selector("div.answer")}
    end
  end

  describe "update question", js: true do
    let(:submit) { 'Update' }

    before do
      find('question_body').set('Example?')
      find('.answers').set('[{"text":"Example.",correct:true}]')
      find('.question_type').set('multipleAnswers')
      find('.title').set('foobarbaz')
    end

    it 'should create a question' do
      expect { find('.btn-primary').click }.to change(AssessmentQuestion, :count).by(1)
    end
  end
end