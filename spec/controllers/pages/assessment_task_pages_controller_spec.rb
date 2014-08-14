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
    let(:response_1) { AssessmentTaskResponse.create(task: assessment_task, school_class: school_class, student: student, completed: true, hidden: true) }
    let(:response_2) { AssessmentTaskResponse.create(task: assessment_task, school_class: school_class, student: student_2, completed: true, hidden: true) }
    let(:other_response) { AssessmentTaskResponse.create(task: other_assessment_task, school_class: school_class, student: student, completed: true, hidden: true) }
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
      response_1
      response_2
      other_response
      another_response
      TaskResponse.all.each { |response|
        2.times do
          response.assessment_question_responses << AssessmentQuestionResponse.create(task_response: response)
        end
      }
      sign_in_as(curriculum_designer)
    end

    it "should not change response count" do
      expect do
        xhr :delete, :delete_all_responses, id: assessment_task.id
      end.to_not change(TaskResponse, :count)
    end
    it "should decrease the number of assessment question responses by 6" do
      expect do
        xhr :delete, :delete_all_responses, id: assessment_task.id
      end.to change(AssessmentQuestionResponse, :count).by(-6)
    end
    it "should not delete the assessment question responses of the other assessment task" do
      expect do
        xhr :delete, :delete_all_responses, id: assessment_task.id
      end.to_not change(TaskResponse.find_by(task: other_assessment_task, school_class: school_class, student: student).assessment_question_responses, :count)
    end
    it "should decrease completed response count by 2" do
      expect do
        xhr :delete, :delete_all_responses, id: assessment_task.id
      end.to change(TaskResponse.completed, :count).by(-2)
    end
    it "should decrease hidden response count by 2" do
      expect do
        xhr :delete, :delete_all_responses, id: assessment_task.id
      end.to change(TaskResponse.where(hidden: true), :count).by(-2)
    end
    it "should not set other response to no longer be completed" do
      xhr :delete, :delete_all_responses, id: assessment_task.id
      expect(TaskResponse.find_by(task: other_assessment_task, school_class: school_class, student: student).completed).to eq(true)
    end
    it "should not set other response to longer be hidden" do
      xhr :delete, :delete_all_responses, id: assessment_task.id
      expect(TaskResponse.find_by(task: other_assessment_task, school_class: school_class, student: student).hidden).to eq(true)
    end
    #check completed changes and hidden chjanges
    #check for assesementquestionresponses getting DELEREED
    it "should not delete response_1" do
      xhr :delete, :delete_all_responses, id: assessment_task.id
      expect(TaskResponse.find_by(task: assessment_task, school_class: school_class, student: student)).to_not eq(nil)
    end
    it "should_not delete response_2" do
      xhr :delete, :delete_all_responses, id: assessment_task.id
      expect(TaskResponse.find_by(task: assessment_task, school_class: school_class, student: student_2)).to_not eq(nil)
    end
    it "should not delete another_response" do
      xhr :delete, :delete_all_responses, id: assessment_task.id
      expect(TaskResponse.find_by(task: assessment_task, school_class: another_school_class, student: another_student)).to_not eq(nil)
    end

  end

end