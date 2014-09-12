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
    it { should have_content("Free Response") }
    it { should have_selector("#variant-links-div") }
  end

  describe "answer tests" do
    it { should have_selector("div.answer", :count => 4) }
    describe "add answer", js: true do
      before do
        visit assessment_question_path(assessment_question)
        click_button("Add New Answer Choice")
      end
      it { should have_selector("div.answer", :count => 5) }
    end
    describe "remove answer", js: true, driver: :selenium do
      before do
        4.times do
          click_button("Remove Answer", match: :first)
          page.driver.browser.switch_to.alert.accept
        end
      end
      it { should_not have_selector("div.answer") }
    end
  end

  describe "after changing question type to Multiple Correct", js: true do
    before do
      click_button("Add New Answer Choice")
      select('Multiple Correct', :from => 'ansType')
    end
    it { should_not have_selector('input[type=radio]') }
    it { should have_selector('input[type=checkbox]', :count => 6) }
    it { should_not have_selector('div.ischecked') }
  end
  describe "after changing question type to Free Response", js: true do
    before do
      click_button("Add New Answer Choice")
      select('Free Response', :from => 'ansType')
    end
    it { should_not have_selector('input[type=radio]') }
    it { should have_selector('input[type=checkbox]', :count => 1) }
    it { should_not have_selector('div.ischecked') }
    it { should_not have_selector('#addAns') }
    it { should have_selector('#free-response-note') }
  end

  describe "update question", js: true do
    before do
      answer = find(".answerText", match: :first)
      answer.click
      answer.set("ExampleContent")

      title = find("#page-title")
      title.click
      title.set("ExampleTitle")

      question = find("#question-body")
      question.click
      question.set("ExampleQuestion for an rspec test")

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
      expect(RSpecSanitizer::sanitize(assessment_question.question_body)).to eq('ExampleQuestion for an rspec test')
    end

    it "should update the answer text", js: true, diver: :selenium do
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
      expect(parsed).to eq([{text: 'ExampleContent', correct: true},
                            {text: 'This is a toaster. ', correct: false},
                            {text: 'You can trust me.', correct: false},
                            {text: 'Whales can fly.', correct: false},
                            {text: '', correct: false}])
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

  describe "after attempting to update a free response question", js: true do
    before do
      click_button("Add New Answer Choice")
      select('Free Response', :from => 'ansType')
      question = find("#question-body")
      question.click
      question.native.send_keys("While there are no answers, this should correctly update")
    end

    it "should successfully update", driver: :selenium do
      expect do
        click_button("Save changes to")
        wait_for_ajax
        assessment_question.reload
      end.to change(assessment_question, :question_body)
    end
  end

  describe "After creating a variant", js: true do
    before do
      click_button "Add a variant"
      wait_for_ajax
    end
    it { should have_selector('.variant-link', :count => 1) }
    it { should have_button('New Question') }

    describe "After then visiting the variant" do
      before do
        click_button "New Question"
      end

      it { should have_selector('.variant-link', :count => 1) }
      it { should have_button("#{assessment_question.title}") }

      describe "After again creating a new variant" do
        before do
          click_button "Add a variant"
          wait_for_ajax
        end
        it { should have_selector('.variant-link', :count => 2) }
        it { should have_button('New Question') }

        describe "After returning to the first question" do
          before do
            click_button "#{assessment_question.title}"
          end
          it { should have_selector('.variant-link', :count => 2) }
          it { should have_button('New Question', :count => 2) }
        end
      end
    end

    describe "when at the assessment task page" do
      before do
        click_link "return to parent (#{assessment_question.assessment_task.title})"
      end

      it { should have_link("#{assessment_question.title}, New Question", href: assessment_question_path(assessment_question.id)) }
      it { should_not have_link("", href: assessment_question_path(AssessmentQuestion.last)) }
    end

    describe "after deleting the original assessment question that has multiple children", driver: :selenium do
      before do
        click_button "Add a variant"
        wait_for_ajax
      end

      it "should delete the assessment question" do
        expect do
          click_link("Delete #{assessment_question.title}")
          page.driver.browser.switch_to.alert.accept
          wait_for_ajax
        end.to change(AssessmentQuestion, :count).by(-1)
      end

      describe "that worked correctly" do
        before do
          click_link("Delete #{assessment_question.title}")
          page.driver.browser.switch_to.alert.accept
          wait_for_ajax
        end
        it { should_not have_link("", href: assessment_question_path(assessment_question.id)) }
        it { should have_link("New Question, New Question", href: assessment_question_path(AssessmentQuestion.last.id - 1)) }
      end

    end
  end


end