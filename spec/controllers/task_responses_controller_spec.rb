require 'spec_helper'

describe TaskResponsesController, type: :controller do
  let(:school_class) { FactoryGirl.create(:school_class) }
  let(:student) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }
  let(:laplaya_task) { FactoryGirl.create(:laplaya_task) }
  let(:assessment_task) { FactoryGirl.create(:assessment_task) }
  let(:laplaya_unlock) { Unlock.create(student: student, school_class: school_class, unlockable: laplaya_task) }
  let(:assessment_unlock) { Unlock.create(student: student, school_class: school_class, unlockable: assessment_task, hidden: true) }
  let(:laplaya_response) { LaplayaTaskResponse.new_response(student, school_class, laplaya_task) }
  let(:assessment_response) { AssessmentTaskResponse.create(student: student, school_class: school_class, task: assessment_task, completed: true) }

  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  before do
    school_class
    student
    sign_in_as(super_staff)
  end

  describe 'reset method' do
    describe 'reseting a laplaya task response' do
      before do
        laplaya_task
        laplaya_unlock
        laplaya_response.update(completed: true)
        request.env["HTTP_REFERER"] = "school_classes/#{school_class.id}/activities/#{laplaya_task.activity_page.id}/reset"
      end

      it 'should remove the response' do
        #it 'should not remove the response' do
        expect do
          xhr :delete, :reset, id: laplaya_response, task_response_id: school_class
        end.to change(LaplayaTaskResponse, :count).by (-1)
        #end.to_not change(LaplayaTaskResponse, :count)
      end
      it 'should delete a laplaya file' do
        expect do
          xhr :delete, :reset, id: laplaya_response, task_response_id: school_class
        end.to change(LaplayaFile, :count).by (-1)
      end
      it 'should not change the number of unlocks' do
        #it 'should not lock any task responses' do
        expect do
          xhr :delete, :reset, id: laplaya_response, task_response_id: school_class
        end.to_not change(Unlock, :count)
        #end.to_not change(TaskResponse.unlocked, :count)
      end
      it 'should make a task response be no longer completed' do
        expect do
          xhr :delete, :reset, id: laplaya_response, task_response_id: school_class
        end.to change(TaskResponse.completed, :count).by (-1)
      end
    end
    describe 'reseting an assessment task response' do
      before do
        assessment_task
        assessment_unlock
        assessment_response.assessment_question_responses << AssessmentQuestionResponse.create(task_response: assessment_response)
        request.env["HTTP_REFERER"] = "school_classes/#{school_class.id}/activities/#{laplaya_task.activity_page.id}/reset"
      end

      it 'should remove the response' do
        #it 'should not remove the response' do
        expect do
          xhr :delete, :reset, id: assessment_response, task_response_id: school_class
        end.to change(AssessmentTaskResponse, :count).by (-1)
        #end.to_not change(AssessmentTaskResponse, :count)
      end
      it 'should delete an assessment question response' do
        expect do
          xhr :delete, :reset, id: assessment_response, task_response_id: school_class
        end.to change(AssessmentQuestionResponse, :count).by (-1)
      end
      it 'should not change the number of unlocks' do
        #it 'should not lock any task responses' do
        expect do
          xhr :delete, :reset, id: assessment_response, task_response_id: school_class
        end.to_not change(Unlock, :count)
        #end.to_not change(TaskResponse.unlocked, :count)
      end
      it 'should make a task response be no longer completed' do
        expect do
          xhr :delete, :reset, id: assessment_response, task_response_id: school_class
        end.to change(TaskResponse.completed, :count).by (-1)
      end
      it 'should make an unlock be no longer hidden' do
      #it 'should make a task response be no longer hidden' do
        expect do
          xhr :delete, :reset, id: assessment_response, task_response_id: school_class
          end.to change(Unlock.where(hidden: true), :count).by(-1)
        #end.to change(TaskResponse.where(hidden: true), :count).by (-1)
      end
    end
  end
end