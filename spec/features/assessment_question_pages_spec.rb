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
        click_on("addAns")
      end
      it { should have_selector("div.answer", :count => 2) }
    end
    describe "remove answer", js: true do
      before do
        first(".deleteAnswer").click
        page.driver.browser.switch_to.alert.accept
      end
      it { should_not have_selector("div.answer") }
    end
  end

  describe "change question type", js: true do
    before do
      click_on("addAns")
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
      answer.native.send_keys("ExampleContent")

      title = find("#page-title")
      clear_text_box(title)
      title.native.send_keys("ExampleTitle")

      question = find("#question-body")
      clear_text_box(question)
      question.native.send_keys("ExampleQuestion")

      select('Multiple Correct', :from => 'ansType')
      click_on ("addAns")
      first(".choices").click
    end

    it "should update the question title" do
      expect do
        click_on("update-page-btn")
        wait_for_ajax
        assessment_question.reload
      end.to change(assessment_question, :title).to('ExampleTitle')
    end

    it "should update the question body" do
      expect do
        click_on("update-page-btn")
        wait_for_ajax
        assessment_question.reload
      end.to change(assessment_question, :question_body).to('<p>ExampleQuestion<br></p>')
    end

    it "should update the answer text" do
      expect do
        click_on("update-page-btn")
        wait_for_ajax
        assessment_question.reload
      end.to change(assessment_question, :answers).to('[{"text":"ExampleContent<p><br></p>","correct":true},{"text":"<p><br></p>","correct":false}]')
    end

    it "should update the question type" do
      expect do
        click_on("update-page-btn")
        wait_for_ajax
        assessment_question.reload
      end.to change(assessment_question, :question_type).to('multipleAnswers')
    end

  end

  describe "remove a question", js: true do

    it "should delete the question" do
      expect do
        click_on("delete-page-link")
        page.driver.browser.switch_to.alert.accept
        wait_for_ajax
      end.to change(AssessmentQuestion, :count).by(-1)
    end
  end

  describe "attempt to update an invalid question", js: true do
    before do
      click_on("addAns")
      select('Multiple Correct', :from => 'ansType')
      question = find("#question-body")
      question.click
      question.native.send_keys("INVALID UPDATE")
    end

    it "should not successfully update" do
      expect do
        click_on("update-page-btn")
        page.driver.browser.switch_to.alert.accept
        wait_for_ajax
        assessment_question.reload
      end.not_to change(assessment_question,:question_body)
    end
  end


end