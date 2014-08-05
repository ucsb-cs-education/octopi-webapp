require 'spec_helper'

describe "teacher view of an activity page", type: :feature do
  subject { page }
  let(:school_class) { FactoryGirl.create(:school_class) }
  let(:teacher) { FactoryGirl.create(:staff, :teacher) }
  let(:activity_page) { FactoryGirl.create(:activity_page) }
  let(:task_one) { FactoryGirl.create(:assessment_task, activity_page: activity_page) }
  let(:task_two) { FactoryGirl.create(:laplaya_task, activity_page: activity_page) }
  let(:student_one) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }
  let(:student_two) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }

  before(:each) do
    school_class
    student_one
    student_two
    school_class.module_pages << task_one.activity_page.module_page
    activity_page.tasks << task_one
    activity_page.tasks << task_two
    task_two.depend_on(task_one)
    activity_page.find_unlock_for(student_one, school_class)
    activity_page.find_unlock_for(student_two, school_class)
    sign_in_as(teacher)

    #need the relevant unlocks to exist
    task_one.get_visibility_status_for(student_one,school_class)
    task_one.get_visibility_status_for(student_two,school_class)
    task_two.get_visibility_status_for(student_one,school_class)
    task_two.get_visibility_status_for(student_two,school_class)
    visit(school_class_activity_path(school_class, activity_page))
  end

  describe "with valid content" do
    it { should have_content(activity_page.title) }
    it { should have_css("div.student-status", :count => 4) }
    it { should have_css("div.unlock-button", :count => 2) }
  end

  describe "that correctly links back" do
    before do
      click_on "Back"
    end
    it "should link to the school class" do
      expect(current_path).to eq(school_class_path(school_class))
    end
  end

  describe "with correctly working unlock buttons", js: true do
    describe "when a single unlock button is pressed" do
      it "should create a single unlock" do
        expect do
          first("input[value='Unlock']").click
          wait_for_ajax
        end.to change(Unlock, :count).by(1)
      end
      describe "that updates the page correctly" do
        before do
          first("input[value='Unlock']").click
          wait_for_ajax
        end
        describe "should remove one unlock button" do
          it { should have_css("div.unlock-button", :count => 1) }
        end
      end
    end
    describe "when unlock for all is pressed" do
      describe "when no students have unlocked the task" do
        it "should create multiple unlocks" do
          expect do
            click_on "Unlock For All"
            wait_for_ajax
          end.to change(Unlock, :count).by(2)
        end
        describe "that updates the page correctly" do
          before do
            click_on "Unlock For All"
            wait_for_ajax
          end
          describe "should remove both unlock buttons" do
            it { should_not have_css("div.unlock-button") }
          end
        end
      end
      describe "when a student has already unlocked the task" do
        before do
          first("input[value='Unlock']").click
          wait_for_ajax
        end
        it "should create one unlock" do
          expect do
            click_on "Unlock For All"
            wait_for_ajax
          end.to change(Unlock, :count).by(1)
        end
        describe "that updates the page correctly" do
          before do
            first("input[value='Unlock']").click
            wait_for_ajax
            click_on "Unlock For All"
            wait_for_ajax
          end
          describe "should remove the unlock button" do
            it { should_not have_css("div.unlock-button") }
          end
        end
      end
    end
  end

  describe "that shows student status correctly" do
    describe "before a student completes a task" do
      it { should_not have_css("span.completed-span") }
      it { should have_css("span.unlocked-span", :count => 2) }
      it { should have_css("div.unlock-button", :count => 2) }
    end
    describe "after a student completed a task" do
      before do
        TaskResponse.create(school_class: school_class, student: student_one, task: task_one, completed: true)
        visit(school_class_activity_path(school_class, activity_page))
      end
      it { should have_css("span.completed-span", :count => 1) }
      it { should have_css("span.unlocked-span", :count => 2) }
      it { should have_css("div.unlock-button", :count => 1) }
    end
  end

  describe "when in an activity no students have unlocked" do
    let(:locked_activity_page) { FactoryGirl.create(:activity_page, module_page: activity_page.module_page) }
    before do
      locked_activity_page.depend_on(task_two)
      visit(school_class_activity_path(school_class, locked_activity_page))
    end
    describe "with correct content" do
      it { should have_css("div.unlock-button", :count => 2) }
      it { should_not have_css("div.student-status") }
    end
    describe "with correctly working unlock buttons", js: true do
      describe "when a single unlock button is pressed" do
        it "should create a single unlock" do
          expect do
            first("input[value='Unlock']").trigger('click')
            wait_for_ajax
          end.to change(Unlock, :count).by(1)
        end
        describe "that updates the page correctly" do
          before do
            first("input[value='Unlock']").trigger('click')
            wait_for_ajax
          end
          describe "should remove one unlock button" do
            it { should have_css("div.unlock-button", :count => 1) }
          end
        end
      end
      describe "when unlock for all is pressed", js: true do
        it "should create multiple unlocks" do
          expect do
            first("input[value='Unlock For All']").click()
            wait_for_ajax
          end.to change(Unlock, :count).by(2)
        end
        describe "that updates the page correctly" do
          before do
            first("input[value='Unlock For All']").click()
            wait_for_ajax
          end
          describe "should remove both unlock buttons" do
            it { should_not have_css("div.unlock-button") }
          end
        end
      end
    end
  end
end