require 'spec_helper'


describe "Assessment question page", type: :feature do

  subject { page }

  let(:assessment_question) { FactoryGirl.create(:assessment_question) }
  let(:user) { FactoryGirl.create(:staff, :super_staff) }

  before do
    sign_in_as_staff(user)
    visit assessment_question_path(assessment_question)
  end

  describe "valid page" do
    it { should have_content("Add New Answer Choice") }
    it { should have_content("One Correct") }
    it { should have_content("Multiple Correct") }
  end

  describe "answer tests" do
    it { should have_selector("div.answer", :count => 1) }
    describe "add answer", js: true do
      before do
        visit assessment_question_path(assessment_question)
        click_button("Add New Answer Choice")
      end
      it { should have_selector("div.answer", :count => 2) }
    end
    describe "remove answer", js: true, driver: :selenium do
      before do
        click_button("Remove Answer")
        page.driver.browser.switch_to.alert.accept
      end
      it { should_not have_selector("div.answer") }
    end
  end

  describe "change question type", js: true do
    before do
      click_button("Add New Answer Choice")
      select('Multiple Correct', :from => 'ansType')
    end
    it { should_not have_selector('input[type=radio]') }
    it { should have_selector('input[type=checkbox]', :count => 2) }
    it { should_not have_selector('div.ischecked') }
    it { should have_selector('div.isNotchecked') }
  end

  describe "update question", js: true do
    before do
      answer = find(".answerText")
      answer.click
      answer.set("ExampleContent")

      title = find("#page-title")
      title.click
      title.set("ExampleTitle")

      question = find("#question-body")
      question.click
      question.set("ExampleQuestion")

      select('Multiple Correct', :from => 'ansType')
      click_button("Add New Answer Choice")
      first(".choices").click
    end

    it "should update the question title" do
      expect do
        click_button("Save changes to")
        wait_for_ajax
        assessment_question.reload
      end.to change(assessment_question, :title).to('ExampleTitle')
    end

    it "should update the question body" do
      expect do
        click_button("Save changes to")
        wait_for_ajax
        assessment_question.reload
      end.to change(assessment_question, :question_body)
      expect(RSpecSanitizer::sanitize(assessment_question.question_body)).to eq('ExampleQuestion')
    end

    it "should update the answer text" do
      expect do
        click_button("Save changes to")
        wait_for_ajax
        assessment_question.reload
      end.to change(assessment_question, :answers)
      parsed = JSON.parse(assessment_question.answers, {symbolize_names: true})
      parsed.map! do |x|
        x[:text] = RSpecSanitizer::sanitize(x[:text])
        x
      end
      expect(parsed).to eq([{text: 'ExampleContent', correct: true}, {text: '', correct: false}])
    end

    it "should update the question type" do
      expect do
        click_button("Save changes to")
        wait_for_ajax
        assessment_question.reload
      end.to change(assessment_question, :question_type).to('multipleAnswers')
    end

  end

  describe "remove a question", js: true, driver: :selenium do

    it "should delete the question" do
      expect do
        click_link("Delete #{assessment_question.title}")
        page.driver.browser.switch_to.alert.accept
        wait_for_ajax
      end.to change(AssessmentQuestion, :count).by(-1)
    end
  end

  describe "attempt to update an invalid question", js: true do
    before do
      click_button("Add New Answer Choice")
      select('Multiple Correct', :from => 'ansType')
      question = find("#question-body")
      question.click
      question.native.send_keys("INVALID UPDATE")
    end

    it "should not successfully update", driver: :selenium do
      expect do
        click_button("Save changes to")
        page.driver.browser.switch_to.alert.accept
        wait_for_ajax
        assessment_question.reload
      end.not_to change(assessment_question, :question_body)
    end
  end


end