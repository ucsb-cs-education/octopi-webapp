require 'spec_helper'
require 'controllers/pages/shared_examples_for_page_controllers'

describe Pages::AssessmentTasksController, type: :controller do
  let(:controller_symbol) { :assessment_task }
  let(:student) { FactoryGirl.create(:student) }
  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  let(:staff) { FactoryGirl.create(:staff) }
  let(:myself) { FactoryGirl.create(:assessment_task) }
  let(:myModel) { AssessmentTask }
  let(:parent_id_symbol) { :activity_page_id }
  let(:my_children) { :assessment_question }

  before do
    sign_in_as_staff(super_staff)
  end

  describe "that should act like a page controller" do
    include_examples Pages::PagesController
  end

  it_behaves_like "a controller that can create and destroy"
  it_behaves_like "a controller with children"

  describe "after deleting all responses" do
    let(:curriculum) { FactoryGirl.create(:curriculum_page) }
    let(:curriculum_designer) { FactoryGirl.create(:staff, :curriculum_designer, curriculum: curriculum) }
    let(:school_class) { FactoryGirl.create(:school_class) }
    let(:another_school) { FactoryGirl.create(:school) }
    let(:another_school_class) { FactoryGirl.create(:school_class, school: another_school) }
    let(:student) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }
    let(:student_2) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }
    let(:another_student) { FactoryGirl.create(:student, school: another_school, school_class: another_school_class) }

    let(:assessment_task) { FactoryGirl.create(:assessment_task, curriculum_id: curriculum.id) }
    let(:other_assessment_task) { FactoryGirl.create(:assessment_task, curriculum_id: curriculum.id) }
    let(:response_1) { AssessmentTaskResponse.create(task: assessment_task, school_class: school_class, student: student) }
    let(:response_2) { AssessmentTaskResponse.create(task: assessment_task, school_class: school_class, student: student_2) }
    let(:other_response) { AssessmentTaskResponse.create(task: other_assessment_task, school_class: school_class, student: student) }
    let(:another_response) { AssessmentTaskResponse.create(task: assessment_task, school_class: another_school_class, student: another_student) }

    before do
      school_class
      another_school
      another_school_class
      student
      student_2
      another_student
      assessment_task
      other_assessment_task
      another_school_class.module_pages << assessment_task.activity_page.module_page
      Unlock.create(student: student, school_class: school_class, unlockable: assessment_task, hidden: true)
      Unlock.create(student: student_2, school_class: school_class, unlockable: assessment_task, hidden: true)
      Unlock.create(student: student, school_class: school_class, unlockable: other_assessment_task, hidden: true)
      Unlock.create(student: another_student, school_class: another_school_class, unlockable: assessment_task, hidden: true)
      response_1
      response_2
      other_response
      another_response
      sign_in_as(curriculum_designer)
    end

    it "should decrease response count by 2" do
      expect do
        xhr :delete, :delete_all_responses, id: assessment_task.id
      end.to change(TaskResponse, :count).by(-3)
    end
    it "should not decrease unlock count" do
      expect do
        xhr :delete, :delete_all_responses, id: assessment_task.id
      end.to_not change(Unlock, :count)
    end
    it "should decrease the number of hidden unlocks" do
      expect do
        xhr :delete, :delete_all_responses, id: assessment_task.id
      end.to change(Unlock.where(hidden: true), :count).by(-3)
    end
    it "should increase the number of non-hidden unlocks" do
      expect do
        xhr :delete, :delete_all_responses, id: assessment_task.id
      end.to change(Unlock.where(hidden: false), :count).by(3)
    end
    it "should not make the unlock in a different task unhidden" do
      xhr :delete, :delete_all_responses, id: assessment_task.id
      expect(Unlock.find_by(student: student, school_class: school_class, unlockable: other_assessment_task, hidden: false)).to eq(nil)
    end
    it "should not delete the response in a different task" do
      xhr :delete, :delete_all_responses, id: assessment_task.id
      expect(TaskResponse.find_by(task: other_assessment_task, school_class: school_class, student: student)).to_not eq(nil)
    end
    it "should delete response_1" do
      xhr :delete, :delete_all_responses, id: assessment_task.id
      expect(TaskResponse.find_by(task: assessment_task, school_class: school_class, student: student)).to eq(nil)
    end
    it "should delete response_2" do
      xhr :delete, :delete_all_responses, id: assessment_task.id
      expect(TaskResponse.find_by(task: assessment_task, school_class: school_class, student: student_2)).to eq(nil)
    end
    it "should delete another_response" do
      xhr :delete, :delete_all_responses, id: assessment_task.id
      expect(TaskResponse.find_by(task: assessment_task, school_class: another_school_class, student: another_student)).to eq(nil)
    end

  end

end