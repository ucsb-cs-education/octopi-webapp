require 'spec_helper'

describe "student portal", type: :feature do
  subject { page }

  let(:school_class) { FactoryGirl.create(:school_class) }
  let(:new_student) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }
  let(:curriculum) { FactoryGirl.create(:curriculum_page) }

  let(:module_page) { FactoryGirl.create(:module_page, curriculum_page: curriculum) }
  let(:module_page_2) { FactoryGirl.create(:module_page, curriculum_page: curriculum) }
  let(:module_page_not_in_class) { FactoryGirl.create(:module_page, curriculum_page: curriculum) }

  let(:activity_page) { FactoryGirl.create(:activity_page, module_page: module_page) }
  let(:activity_page_locked) { FactoryGirl.create(:activity_page, module_page: module_page) }
  let(:activity_page_not_in_class) { FactoryGirl.create(:activity_page, module_page: module_page) }

  let(:assessment_task) { FactoryGirl.create(:assessment_task, activity_page: activity_page) }
  let(:assessment_task_locked) { FactoryGirl.create(:assessment_task, activity_page: activity_page) }
  let(:assessment_task_not_in_class) { FactoryGirl.create(:assessment_task, activity_page: activity_page) }
  let(:assessment_question) { FactoryGirl.create(:assessment_question, assessment_task: assessment_task) }

  let(:unlock) { Unlock.create(unlockable: activity_page, school_class: school_class, student: new_student, hidden: false) }
  let(:unlock_task) { Unlock.create(unlockable: assessment_task, school_class: school_class, student: new_student, hidden: false) }

  before(:each) do
    school_class
    new_student
    unlock
    unlock_task
    school_class.school.curriculum_pages << curriculum
    school_class.school.school_classes.first.module_pages << module_page
    school_class.school.school_classes.first.module_pages << module_page_2
    module_page.activity_pages << activity_page
    module_page.activity_pages << activity_page_locked
    activity_page.children << assessment_task
    activity_page.children << assessment_task_locked
    assessment_task_locked.depend_on(assessment_task)
    assessment_task.assessment_questions << assessment_question
    activity_page_locked.depend_on(assessment_task)
    sign_in_as(new_student)
    visit(thisPath)
  end

  shared_examples "a standard page" do
    describe "with the correct content" do
      it { should have_selector(".student-body") }
      it { should have_selector("#page-title") }
      it { should_not have_selector("div[class='alert alert-warning']") }
    end
  end


  describe "module page" do
    let(:thisPath) { student_portal_module_path(module_page) }

    describe "after visiting an allowed module page" do
      it_behaves_like "a standard page"
      it { should have_selector("#children-pages") }
      it { should_not have_link("#{activity_page_locked.title}", :href => student_portal_activity_path(activity_page_locked)) }
      it { should have_link("#{activity_page.title}", :href => student_portal_activity_path(activity_page)) }

      describe "after changing modules", js: true do
        before do
          select(module_page_2.title, :from => 'modules')
          click_on "change-module-button"
        end
        it "should change to the correct page" do
          expect(find("#page-title")).to have_text(module_page_2.title)
          expect(current_path).to eq(student_portal_module_path(module_page_2))
        end
      end

      describe "after navigation to an unlocked child" do
        before do
          first('.child-link').find('a').click
        end
        it "should redirect to child" do
          expect(current_path).to eq(student_portal_activity_path(activity_page))
        end
      end
    end

    describe "after visiting a module page not in the class" do
      before do
        visit(student_portal_module_path(module_page_not_in_class))
      end
      it { should have_selector("div[class='alert alert-warning']") }
    end
  end


  describe "activity page" do
    let(:thisPath) { student_portal_activity_path(activity_page) }

    describe "after visit an activity you have permission to" do
      it_behaves_like "a standard page"
      it { should have_selector("#children-pages") }
      it { should have_selector("#parent-link") }
      it { should_not have_link("#{assessment_task_locked.title}", :href => student_portal_assessment_task_path(assessment_task_locked)) }
      it { should have_link("#{assessment_task.title}", :href => student_portal_assessment_task_path(assessment_task)) }

      describe "after clicking the parent module link" do
        before do
          find("#parent-link").find("a").click
        end
        it "should redirect to the parent module" do
          expect(current_path).to eq(student_portal_module_path(module_page))
        end
      end

      describe "after navigation to an unlocked child" do
        before do
          first('.child-link').find('a').click
        end
        it "should redirect to child" do
          expect(current_path).to eq(student_portal_assessment_task_path(assessment_task))
        end
      end
    end

    describe "after visiting a not allowed activity page" do
      describe "that is not in the class" do
        before do
          visit(student_portal_activity_path(activity_page_not_in_class))
        end
        it { should have_selector("div[class='alert alert-warning']") }
      end
      describe "that is a locked page" do
        before do
          visit(student_portal_activity_path(activity_page_locked))
        end
        it { should have_selector("div[class='alert alert-warning']") }
      end
    end
  end


  describe "assessment task page" do
    let(:thisPath) { student_portal_assessment_task_path(assessment_task) }

    describe "after visiting an assessment task you have permission to" do
      it_behaves_like "a standard page"
      it { should have_selector(".question-box") }
      it { should have_selector(".question-title") }
      it { should have_selector(".question-box") }
      it { should have_selector("#question-answers") }
      it { should have_selector(".input-box") }
      it { should have_selector(".answer-text") }
      it { should have_selector(".question-box") }
      it { should have_selector(".answer-input") }
      it { should have_selector("#submit-answer-button") }

      describe "after submitting answers", js: true do
        before do
          first(".answer-input").click
        end
        describe "should submit correctly" do
          subject { -> {
            click_button "submit-answer-button"
            wait_for_ajax
          } }
          it { should change(TaskResponse, :count).by(1) }
          it { should change(AssessmentQuestionResponse, :count).by(1) }
          it { should change(Unlock, :count).by(2) }
        end
        describe "after redirecting" do
          before do
            click_button "submit-answer-button"
            wait_for_ajax
          end
          it "should redirect to the parent activity" do
            expect(current_path).to eq(student_portal_activity_path(activity_page))
          end
          it { should have_link("#{assessment_task_locked.title}", :href => student_portal_assessment_task_path(assessment_task_locked)) }
          it { should_not have_link("#{assessment_task.title}", :href => student_portal_assessment_task_path(assessment_task)) }
        end

        describe "after attempting to visit the newly unlocked assessment task" do
          before do
            click_button "submit-answer-button"
            wait_for_ajax
            visit student_portal_assessment_task_path(assessment_task_locked)
          end
          it "should be visitable" do
            expect(current_path).to eq(student_portal_assessment_task_path(assessment_task_locked))

          end
        end

        describe "after attempting to visit the newly unlocked activity page" do
          before do
            click_button "submit-answer-button"
            wait_for_ajax
            visit student_portal_activity_path(activity_page_locked)
          end
          it "should be visitable" do
            expect(current_path).to eq(student_portal_activity_path(activity_page_locked))
          end
        end

        describe "after visiting the module page" do
          before do
            click_button "submit-answer-button"
            wait_for_ajax
            visit student_portal_module_path(module_page)
          end
          describe "should have both activities unlocked" do
            it { should have_link("#{activity_page_locked.title}", :href => student_portal_activity_path(activity_page_locked)) }
            it { should have_link("#{activity_page.title}", :href => student_portal_activity_path(activity_page)) }
          end
        end
      end

    end

    describe "after visiting a not allowed assessment task" do
      describe "that is  not in the class" do
        before do
          visit(student_portal_assessment_task_path(assessment_task_not_in_class))
        end
        it { should have_selector("div[class='alert alert-warning']") }
      end
      describe "that is a locked page" do
        before do
          visit(student_portal_assessment_task_path(assessment_task_locked))
        end
        it { should have_selector("div[class='alert alert-warning']") }
      end
    end
  end
end


