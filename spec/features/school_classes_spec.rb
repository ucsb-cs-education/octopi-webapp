require 'spec_helper'


describe "SchoolClasses", type: :feature do
  shared_examples_for "visible new student form" do
    describe "the new student form" do
      it 'should be visible' do
        visibility = :visible
        expect(find('#new_student', visible: visibility)).to have_field('First name', visible: visibility)
        expect(find('#new_student', visible: visibility)).to have_field('Last name', visible: visibility)
        expect(find('#new_student', visible: visibility)).to have_field('Login', visible: visibility)
        expect(find('#new_student', visible: visibility)).to have_field('Password', visible: visibility)
        expect(find('#new_student', visible: visibility)).to have_field('Password confirmation', visible: visibility)
        expect(find('#new_student', visible: visibility)).to have_button('Cancel', visible: visibility)
        expect(find('#new_student', visible: visibility)).to have_button('Add New Student', visible: visibility)
      end
    end
    describe 'the new student button outside the form' do
      it 'should be hidden' do
        expect(find('#new_student_button', visible: :hidden)).to_not be_visible
      end
    end
  end

  shared_examples_for "hidden new student form" do
    describe "the new student form" do
      it 'should be hidden' do
        visibility = :hidden
        expect(find('#new_student', visible: visibility)).to have_field('First name', visible: visibility)
        expect(find('#new_student', visible: visibility)).to have_field('Last name', visible: visibility)
        expect(find('#new_student', visible: visibility)).to have_field('Login', visible: visibility)
        expect(find('#new_student', visible: visibility)).to have_field('Password', visible: visibility)
        expect(find('#new_student', visible: visibility)).to have_field('Password confirmation', visible: visibility)
        expect(find('#new_student', visible: visibility)).to have_button('Cancel', visible: visibility)
        expect(find('#new_student', visible: visibility)).to have_button('Add New Student', visible: visibility)
      end
    end
    describe 'the new student button outside the form' do
      it 'should be visible' do
        expect(find('#new_student_button', visible: :visible)).to be_visible
      end
    end
  end

  let(:staff) { FactoryGirl.create(:staff, :super_staff) }
  let(:school_class) { FactoryGirl.create(:school_class) }
  subject { page }
  before do
    sign_in_as_staff(staff)
    visit school_class_path(school_class)
  end
  it { should have_content('Curriculum') }
  it { should have_content('About') }
  it { should have_content('School:') }
  it { should have_link('Edit Students', href: edit_school_class_path(school_class)) }
  it { should have_link('Back', href: school_school_classes_path(school_class.school)) }
  it { should have_table("classlist") }

  describe "Edit Page" do
    let(:add_existing_student) do
      FactoryGirl.create(:student, school: school_class.school,
                         school_class: FactoryGirl.create(:school_class, school: school_class.school))
    end
    let(:module_page) { FactoryGirl.create(:assessment_question).assessment_task.activity_page.module_page }
    before(:each) do
      add_existing_student
      school_class.school.curriculum_pages << module_page.curriculum_page
      school_class.module_pages << module_page
      visit edit_school_class_path(school_class)
    end
    it { should have_table("classlist") }
    it { should have_link("Back", href: school_class_path(school_class)) }
    it { should have_content("School:") }
    it { should have_content("Modules in #{module_page.curriculum_page.title.downcase}") }
    it { should have_content(module_page.title) }

    describe "Saving class name" do
      before { click_button 'Save class settings' }
      it { should have_content("Class was successfully updated.") }
    end

    describe "Add existing student" do
      before do
        select add_existing_student.name, from: "existing_student_list"
      end
      it 'should add student to class', js: true do
        expect do
          click_button 'add_existing_student_button'
          wait_for_ajax
        end.to change(school_class.students, :count).by(1)
      end

    end
    describe "adding a new student", js: true do

      let (:student) { FactoryGirl.build(:student) }

      before { click_button 'Add New Student' }

      include_examples "visible new student form"

      describe "clicking the cancel new student button" do
        before { click_button 'Cancel' }
        include_examples "hidden new student form"
      end
      describe "with the right info" do
        before do
          fill_in 'First name', with: student.first_name
          fill_in 'Last name', with: student.last_name
          fill_in 'Login', with: student.login_name
          fill_in 'Password', with: student.password, match: :prefer_exact
          fill_in 'Password confirmation', with: student.password, match: :prefer_exact
        end
        it 'should create a student' do
          expect do
            click_button 'Add New Student'
            wait_for_ajax
          end.to change(Student, :count).by(1)
        end
        describe 'the resulting page' do
          before do
            click_button 'Add New Student'
            wait_for_ajax
          end
          include_examples "hidden new student form"
        end
      end
      describe "with a different password and confirmation" do
        before do
          fill_in 'First name', with: student.first_name
          fill_in 'Last name', with: student.last_name
          fill_in 'Login', with: student.login_name
          fill_in 'Password', with: student.password.downcase, match: :prefer_exact
          fill_in 'Password confirmation', with: student.password.upcase, match: :prefer_exact
        end
        it 'should not create a new student' do
          expect do
            click_button 'Add New Student'
            wait_for_ajax
          end.to_not change(Student, :count)
        end
        describe 'the page' do
          before do
            click_button 'Add New Student'
            wait_for_ajax
          end
          it { should_not have_content(student.name) }
          include_examples "visible new student form"
          it { should have_content('doesn\'t match Password') }
          it { should have_content('Please review the problems below:') }
        end
      end

    end
  end
end