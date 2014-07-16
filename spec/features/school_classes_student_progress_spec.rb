require 'spec_helper'

describe "a teacher view of a student page", type: :feature do
  subject { page }
  let(:school_class) { FactoryGirl.create(:school_class) }
  let(:teacher) { FactoryGirl.create(:staff, :teacher) }
  let(:activity_page) { FactoryGirl.create(:activity_page) }
  let(:task_one) { FactoryGirl.create(:assessment_task, activity_page: activity_page) }
  let(:task_two) { FactoryGirl.create(:laplaya_task, activity_page: activity_page) }
  let(:student) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }

  before(:each) do
    school_class
    student
    activity_page.tasks << task_one
    activity_page.tasks << task_two
    task_two.depend_on(task_one)
    activity_page.find_unlock_for(student, school_class)
    school_class.module_pages << activity_page.module_page
    sign_in_as(teacher)

    #need the relevant unlocks to exist
    task_one.get_visibility_status_for(student,school_class)
    task_two.get_visibility_status_for(student,school_class)
    visit(school_class_student_progress_path(school_class, student))
  end

  describe "with valid content" do
    it { should have_content(student.name) }
    it { should have_css("div[id='curriculum-list']") }
    it { should have_css("li.module-page-li", count: 1) }
    it { should have_css("ul.activity-page-ul", count: 1) }
    it { should have_css("ul.task-ul", count: 1) }
    it { should have_css("li.unlocked-task", count: 1) }
    it { should have_css("li.locked-task", count: 1) }
    it { should_not have_css("li.completed-task") }
  end

  describe "after the back button is pressed" do
    before do
      click_on "Back"
    end
    it "should link to the school class" do
      expect(current_path).to eq(school_class_path(school_class))
    end
  end

  describe "with correctly working unlock buttons", js: true do
    describe "after a task is unlocked" do
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
          it { should_not have_css("div.unlock-button") }
          it { should_not have_css("li.locked-task") }
        end
      end
    end
    describe "after an activity is unlocked", js: true do
      let(:locked_activity_page) { FactoryGirl.create(:activity_page, module_page: activity_page.module_page) }
      before do
        locked_activity_page.depend_on(task_two)
        visit(school_class_student_progress_path(school_class, student))
      end
      it "should create a single unlock" do
        expect do
          find(".locked-activity").first("input[value='Unlock']").click
          wait_for_ajax
        end.to change(Unlock, :count).by(1)
      end
      describe "that updates the page correctly" do
        before do
          find(".locked-activity").first("input[value='Unlock']").click
          wait_for_ajax
        end
        describe "should remove one unlock button" do
          it { should_not have_css("li.locked-activity") }
          it { should have_css("div.unlock-button", count: 1) }
        end
      end
    end
  end


end