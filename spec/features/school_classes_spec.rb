require 'spec_helper'

describe "SchoolClasses", type: :feature do
  let(:staff){FactoryGirl.create(:staff,:super_staff)}
  let(:school_class){FactoryGirl.create(:school_class)}
  subject{page}
  before do
    sign_in_as_staff(staff)
    visit school_class_path(school_class)
  end
  it { should have_content('Curriculum') }
  it { should have_content('About') }
  it { should have_content('School:')}
  it { should have_link('Edit Students',href:edit_school_class_path(school_class)) }
  it { should have_link('Back', href: school_school_classes_path(school_class.school))}
  it { should have_table("classlist")}

  describe "Edit Page" do
    let(:add_existing_student) do
      FactoryGirl.create(:student, school: school_class.school,
                         school_class: FactoryGirl.create(:school_class, school: school_class.school))
    end
    before(:each) do
      FactoryGirl.create(:student, school: school_class.school,
                         school_class: FactoryGirl.create(:school_class, school: school_class.school))
      add_existing_student
      visit edit_school_class_path(school_class)
    end
    it {should have_table("classlist")}
    it {should have_link("Back", href:school_class_path(school_class))}
    it {should have_content("School:")}
    describe "Saving class name" do
      before {click_button "Save class name"}
      it {should have_content("Class was successfully updated.")}
    end
    describe "Add existing student", js: true do

      it 'should add student to class' do
        expect do
          select add_existing_student.name, from: "existing_student_list"
          click_button 'add_existing_student_button'
          wait_for_ajax
        end.to change(school_class.students, :count).by(1)
      end
    end
    describe "Add new student", js: true do
      before  {click_button'Add New Student'}
      it {should have_selector("button[id='cancel_button']")}
      it {should have_content("Password")}
      describe "Cancel new student" do
        before {click_button 'Cancel'}
        it {should_not have_content("Password")}
        it {should_not have_selector("button[id='cancel_button']")}
        it {should have_selector("button[id='toggle_button']")}
      end
      describe "Fill in right info" do
        before do
          fill_in 'First name', with: 'girl'
          fill_in 'Last name', with: 'last'
          fill_in 'Login', with: 'loginnn'
          fill_in 'Password', with: 'foobarbaz'
          fill_in 'Password confirmation', with: 'foobarbaz'
        end
        it 'should create a student' do
          expect do
            click_button 'Add New Student'
            wait_for_ajax
          end.to change(Student, :count).by(1)
        end
      end
      describe "Fill in different password and confirmation info" do
        before do
          fill_in 'First name', with: 'girl'
          fill_in 'Last name', with: 'last'
          fill_in 'Login', with: 'loginnn'
          fill_in 'Password', with: 'foobarbaz'
          fill_in 'Password confirmation', with: 'foobarba'
        end
        it {should_not have_content 'loginnn'}
      end

    end
  end
end