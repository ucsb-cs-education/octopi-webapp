require 'spec_helper'
require 'controllers/pages/shared_examples_for_page_controllers'
require 'controllers/pages/shared_examples_for_laplaya_cloning'

describe Pages::LaplayaTasksController, type: :controller do
  let(:controller_symbol) { :laplaya_task }
  let(:student) { FactoryGirl.create(:student) }
  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  let(:staff) { FactoryGirl.create(:staff) }
  let(:myself) { FactoryGirl.create(:laplaya_task) }
  let(:myModel) { LaplayaTask }
  let(:parent_id_symbol) { :activity_page_id }

  before do
    sign_in_as_staff(super_staff)
  end

  describe "that should act like a page controller" do
    include_examples Pages::PagesController
  end

  it_behaves_like "a controller that can create and destroy"

  describe "its base file" do
    let(:laplaya_clone_action) { :clone }
    let(:laplaya_file_being_cloned_to) { myself.task_base_laplaya_file }
    let(:current_user) { super_staff }
    let(:my_path) { laplaya_task_url(myself) }
    include_examples 'pages laplaya cloning'
  end

  describe "after resetting all responses" do
    let(:curriculum) { FactoryGirl.create(:curriculum_page) }
    let(:curriculum_designer) { FactoryGirl.create(:staff, :curriculum_designer, curriculum: curriculum) }
    let(:school_class) { FactoryGirl.create(:school_class) }
    let(:another_school) { FactoryGirl.create(:school) }
    let(:another_school_class) { FactoryGirl.create(:school_class, school: another_school) }
    let(:student) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }
    let(:student_2) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }
    let(:another_student) { FactoryGirl.create(:student, school: another_school, school_class: another_school_class) }

    let(:laplaya_task) { FactoryGirl.create(:laplaya_task, curriculum_id: curriculum.id) }
    let(:other_laplaya_task) { FactoryGirl.create(:laplaya_task, curriculum_id: curriculum.id) }
    let(:response_1) { LaplayaTaskResponse.create(task: laplaya_task, school_class: school_class, student: student, completed: true) }
    let(:response_2) { LaplayaTaskResponse.create(task: laplaya_task, school_class: school_class, student: student_2, completed: true) }
    let(:other_response) { LaplayaTaskResponse.create(task: other_laplaya_task, school_class: school_class, student: student, completed: true) }
    let(:another_response) { LaplayaTaskResponse.create(task: laplaya_task, school_class: another_school_class, student: another_student) }
    before do
      school_class
      another_school
      another_school_class
      student
      student_2
      another_student
      laplaya_task
      other_laplaya_task
      another_school_class.module_pages << laplaya_task.activity_page.module_page
      response_1
      response_2
      other_response
      another_response
      TaskResponse.all.each { |response|
        response.make_laplaya_file_for(response.task)
      }
      sign_in_as(curriculum_designer)
    end

    it "should not change the number of responses" do
      expect do
        xhr :delete, :delete_all_responses, id: laplaya_task.id
      end.to_not change(TaskResponse, :count)
    end
    it "should decrease completed response count by 2" do
      expect do
        xhr :delete, :delete_all_responses, id: laplaya_task.id
      end.to change(TaskResponse.completed, :count).by(-2)
    end
    it "should not delete the response in a different task" do
      xhr :delete, :delete_all_responses, id: laplaya_task.id
      expect(TaskResponse.find_by(task: other_laplaya_task, school_class: school_class, student: student)).to_not eq(nil)
    end
    it "should not delete response_1" do
      xhr :delete, :delete_all_responses, id: laplaya_task.id
      expect(TaskResponse.find_by(task: laplaya_task, school_class: school_class, student: student)).to_not eq(nil)
    end
    it "should not delete response_2" do
      xhr :delete, :delete_all_responses, id: laplaya_task.id
      expect(TaskResponse.find_by(task: laplaya_task, school_class: school_class, student: student_2)).to_not eq(nil)
    end
    it "should not delete another_response" do
      xhr :delete, :delete_all_responses, id: laplaya_task.id
      expect(TaskResponse.find_by(task: laplaya_task, school_class: another_school_class, student: another_student)).to_not eq(nil)
    end
    it "should not set other response to no longer be completed" do
      xhr :delete, :delete_all_responses, id: laplaya_task.id
      expect(TaskResponse.find_by(task: other_laplaya_task, school_class: school_class, student: student).completed).to eq(true)
    end
    it "should decrease the number of laplaya files by three" do
      expect do
        xhr :delete, :delete_all_responses, id: laplaya_task.id
      end.to change(LaplayaFile, :count).by(-3)
    end
  end

end