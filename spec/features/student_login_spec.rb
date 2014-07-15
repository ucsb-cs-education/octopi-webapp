require 'spec_helper'

describe "For the student portal,", js: true, type: :feature do
  let(:school_class) { FactoryGirl.create(:school_class) }
  let(:new_student) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }
  let(:second_school_class) { FactoryGirl.create(:school_class) }
  let(:second_new_student) { FactoryGirl.create(:student, school: second_school_class.school, school_class: second_school_class) }
  let(:second_school) {FactoryGirl.create(:school)}
  let(:third_school_class) { FactoryGirl.create(:school_class, school: second_school) }
  let(:third_new_student) { FactoryGirl.create(:student, school: second_school, school_class: third_school_class) }
  subject{page}
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
    it { should_not have_content("Student signed in")}
    describe " while not selecting school class and login name" do
      before { click_button "Sign in" }
      it { should have_error_message "Invalid email/password combination" }
    end
    describe " when entering the right password" do
      before do
        select school_class.name, from: 'session_school_class'
        wait_for_ajax
        select new_student.login_name, from: 'session_login_name'
        fill_in "session_password", with: new_student.password
        click_button "Sign in"
      end
      it {should_not have_content("Invalid email/password combination")}
      describe " will stay logged in" do
        before {visit student_portal_signin_path}
        it do
          should have_content("Student signed in")
          should have_content(new_student.name)
        end
      end
    end
    describe " when entering the wrong password" do
      before do
        select school_class.name, from: 'session_school_class'
        wait_for_ajax
        select new_student.login_name, from: 'session_login_name'
        fill_in "Password", with: "wrong"
        click_button "Sign in"
      end
      it { should have_error_message("Invalid email/password combination") }
    end
    describe "a student not in the class should not appear in the dropdown" do
      before {select school_class.name, from: 'session_school_class'}
      it do
        find_field('session_school_class').text.should have_text(second_school_class.name)
        find_field('session_school_class').text.should have_text(school_class.name)
        find_field('session_school_class').text.should_not have_text(third_school_class.name)
        find_field('session_login_name').text.should_not have_text(second_new_student.login_name)
        find_field('session_login_name').text.should_not have_text(third_new_student.login_name)
        find_field('session_login_name').text.should have_text(new_student.login_name)
      end
      describe " and the same when switching the class" do
        before {select second_school_class.name, from: 'session_school_class'}
        it do
          find_field('session_login_name').text.should have_text(second_new_student.login_name)
          find_field('session_login_name').text.should_not have_text(third_new_student.login_name)
          find_field('session_login_name').text.should_not have_text(new_student.login_name)
        end
      end
    end
    describe "a class not in the school should not appear in the dropdown and no students should show when switching schools" do
      before {select second_school.name, from: 'session_school'}
      it do
        find_field('session_school_class').text.should_not have_text(second_school_class.name)
        find_field('session_school_class').text.should_not have_text(school_class.name)
        find_field('session_school_class').text.should have_text(third_school_class.name)
        find_field('session_login_name').text.should_not have_text(second_new_student.login_name)
        find_field('session_login_name').text.should_not have_text(new_student.login_name)
        find_field('session_login_name').text.should_not have_text(third_new_student.login_name)
      end
      describe " and should show the student when clicking the class" do
        before {select third_school_class.name, from: 'session_school_class'}
        it do
          find_field('session_login_name').text.should_not have_text(second_new_student.login_name)
          find_field('session_login_name').text.should_not have_text(new_student.login_name)
          find_field('session_login_name').text.should have_text(third_new_student.login_name)
        end
      end
    end
  end
end