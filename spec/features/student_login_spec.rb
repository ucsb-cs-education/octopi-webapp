require 'spec_helper'

describe "For the student portal,", js: true, type: :feature do
  let(:school_class) { FactoryGirl.create(:school_class) }
  let(:new_student) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }
  let(:second_school_class) { FactoryGirl.create(:school_class) }
  let(:second_new_student) { FactoryGirl.create(:student, school: second_school_class.school, school_class: second_school_class) }
  let(:second_school) { FactoryGirl.create(:school) }
  let(:third_school_class) { FactoryGirl.create(:school_class, school: second_school) }
  let(:third_new_student) { FactoryGirl.create(:student, school: second_school, school_class: third_school_class) }
  let(:class_prompt) { 'Please select a class' }
  let(:login_prompt) { 'Please select a login name' }
  subject { page }
  before(:each) do
    school_class
    new_student
    second_school_class
    third_school_class
    third_new_student
    second_new_student
    second_school
    visit student_portal_signin_path
  end
  describe "on the login page" do
    it { should have_button("Sign in") }
    it { should_not have_content("Student signed in") }
    describe " while not selecting school class and login name" do
      before { click_button "Sign in" }
      it { should have_error_message "Please select a class and/or login name" }
    end
    describe " when entering the right password" do
      before { sign_in_as_student(new_student) }
      it do
        expect(current_path).to eq(student_portal_root_path)
        should_not have_content("Invalid login/password combination")
      end
      describe " will stay logged in" do
        before { visit student_portal_signin_path }
        it do
          expect(current_path).to eq(student_portal_root_path)
          should have_content("Student signed in")
          should have_content(new_student.name)
        end
      end
    end
    describe " when entering the wrong password" do
      before do
        select school_class.school, from: 'School'
        wait_for_ajax
        select school_class.name, from: 'Class name'
        wait_for_ajax
        select new_student.login_name, from: 'Login name'
        fill_in "Password", with: "wrong"
        click_button "Sign in"
      end
      it { should have_error_message("Invalid login/password combination") }
    end
    describe "a student not in the class should not appear in the dropdown" do
      before do
        select school_class.school, from: 'School'
        wait_for_ajax
        select school_class.name, from: 'Class name'
        wait_for_ajax
      end
      it do
        #have select is exact! should_not is here for completeness sake
        should have_select('Class name', options: [class_prompt, second_school_class.name, school_class.name])
        should_not have_select('Class name', options: [class_prompt, second_school_class.name])
        should have_select('Login name', options: [login_prompt, new_student.login_name])
      end
      describe " and the same when switching the class" do
        before do
          select second_school_class.name, from: 'Class name'
          wait_for_ajax
        end
        it do
          should have_select('Login name', options: [login_prompt, second_new_student.login_name])
        end
      end
    end
    describe "a class not in the school should not appear in the dropdown and no students should show when switching schools" do
      before do
        select second_school.name, from: 'School'
        wait_for_ajax
      end
      it do
        should have_select('Class name', options: [class_prompt, third_school_class.name])
        should have_select('Login name', options: [login_prompt])
      end
      describe " and should show the student when clicking the class" do
        before { select third_school_class.name, from: 'Class name' }
        it do
          should have_select('Login name', options: [login_prompt, third_new_student.login_name])
        end
      end
    end
  end
end