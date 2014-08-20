require 'spec_helper'

describe SchoolClassesController, type: :controller do
  let(:school_class) { FactoryGirl.create(:school_class) }
  let(:other_school_class) { FactoryGirl.create(:school_class) }


  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  before do
    school_class
    other_school_class
    sign_in_as(super_staff)
  end

  shared_examples_for 'a kind of task' do
    it 'should remove the responses' do
      #it 'should not remove the response' do
      expect do
        xhr :delete, :reset_task, id: school_class, task: {task_id: task}
      end.to change(TaskResponse, :count).by (-3)
      #end.to_not change(TaskResponse, :count)
    end
    it 'should delete the additional files' do
      expect do
        xhr :delete, :reset_task, id: school_class, task: {task_id: task}
      end.to change(child, :count).by (-3)
    end
    it 'should not change the number of unlocks' do
      #it 'should not lock any task responses' do
      expect do
        xhr :delete, :reset_task, id: school_class, task: {task_id: task}
      end.to_not change(Unlock, :count)
      #end.to_not change(TaskResponse.unlocked, :count)
    end
    it 'should make task responses be no longer completed' do
      expect do
        xhr :delete, :reset_task, id: school_class, task: {task_id: task}
      end.to change(TaskResponse.completed, :count).by (-3)
    end
  end

  describe 'Resetting a task' do
    describe 'that is a laplaya task' do
      let(:task) { FactoryGirl.create(:laplaya_task) }
      let(:child) { LaplayaFile }
      before do
        task
        3.times do
          new_student = FactoryGirl.create(:student, school: school_class.school, school_class: school_class)
          Unlock.create(student: new_student, unlockable: task, school_class: school_class)
          LaplayaTaskResponse.new_response(new_student, school_class, task).update(completed: true)
        end
        other_student = FactoryGirl.create(:student, school: other_school_class.school, school_class: other_school_class)
        Unlock.create(student: other_student, unlockable: task, school_class: other_school_class)
        LaplayaTaskResponse.new_response(other_student, other_school_class, task).update(completed: true)
        request.env["HTTP_REFERER"] = "school_classes/#{school_class.id}/activities/#{task.activity_page.id}/reset"
      end

      it_behaves_like 'a kind of task'
    end

    describe 'that is an assessment task' do
      let(:task) { FactoryGirl.create(:assessment_task) }
      let(:child) { AssessmentTaskResponse }
      before do
        task
        3.times do
          new_student = FactoryGirl.create(:student, school: school_class.school, school_class: school_class)
          Unlock.create(student: new_student, unlockable: task, school_class: school_class, hidden: true)
          response = AssessmentTaskResponse.create(student: new_student, school_class: school_class, task: task, completed: true)
          response.assessment_question_responses << AssessmentQuestionResponse.create(task_response: response)
        end
        other_student = FactoryGirl.create(:student, school: other_school_class.school, school_class: other_school_class)
        Unlock.create(student: other_student, unlockable: task, school_class: other_school_class, hidden: true)
        response = AssessmentTaskResponse.create(student: other_student, school_class: other_school_class, task: task, completed: true)
        response.assessment_question_responses << AssessmentQuestionResponse.create(task_response: response)
        request.env["HTTP_REFERER"] = "school_classes/#{school_class.id}/activities/#{task.activity_page.id}/reset"
      end

      it_behaves_like 'a kind of task'

      it 'should make unlocks be no longer hidden' do
        #it 'should make a task response be no longer hidden' do
        expect do
          xhr :delete, :reset_task, id: school_class, task: {task_id: task}
        end.to change(Unlock.where(hidden: true), :count).by(-3)
        #end.to change(TaskResponse.where(hidden: true), :count).by (-1)
      end
    end
  end

  describe 'Resetting an activity' do
    let(:activity) { FactoryGirl.create(:activity_page) }
    let(:assessment_task) { FactoryGirl.create(:assessment_task) }
    let(:laplaya_task) { FactoryGirl.create(:laplaya_task) }

    before do
      activity
      activity.tasks << assessment_task
      activity.tasks << laplaya_task
      3.times do
        new_student = FactoryGirl.create(:student, school: school_class.school, school_class: school_class)
        Unlock.create(student: new_student, unlockable: laplaya_task, school_class: school_class)
        LaplayaTaskResponse.new_response(new_student, school_class, laplaya_task).update(completed: true)
        Unlock.create(student: new_student, unlockable: assessment_task, school_class: school_class, hidden: true)
        response = AssessmentTaskResponse.create(student: new_student, school_class: school_class, task: assessment_task, completed: true)
        response.assessment_question_responses << AssessmentQuestionResponse.create(task_response: response)
      end
      other_student = FactoryGirl.create(:student, school: other_school_class.school, school_class: other_school_class)
      Unlock.create(student: other_student, unlockable: laplaya_task, school_class: other_school_class)
      LaplayaTaskResponse.new_response(other_student, other_school_class, laplaya_task).update(completed: true)
      Unlock.create(student: other_student, unlockable: assessment_task, school_class: other_school_class, hidden: true)
      response = AssessmentTaskResponse.create(student: other_student, school_class: other_school_class, task: assessment_task, completed: true)
      response.assessment_question_responses << AssessmentQuestionResponse.create(task_response: response)
      request.env["HTTP_REFERER"] = "school_classes/#{school_class.id}/activities/#{activity.id}/reset"
    end

    it 'should remove the responses' do
      #it 'should not remove the response' do
      expect do
        xhr :delete, :reset_activity, id: school_class, activity: {activity_id: activity}
      end.to change(TaskResponse, :count).by (-6)
      #end.to_not change(LaplayaTaskResponse, :count)
    end
    it 'should delete the laplaya files' do
      expect do
        xhr :delete, :reset_activity, id: school_class, activity: {activity_id: activity}
      end.to change(LaplayaFile, :count).by (-3)
    end
    it 'should delete the assessment question responses' do
      expect do
        xhr :delete, :reset_activity, id: school_class, activity: {activity_id: activity}
      end.to change(AssessmentQuestionResponse, :count).by (-3)
    end
    it 'should not change the number of unlocks' do
      #it 'should not lock any task responses' do
      expect do
        xhr :delete, :reset_activity, id: school_class, activity: {activity_id: activity}
      end.to_not change(Unlock, :count)
      #end.to_not change(TaskResponse.unlocked, :count)
    end
    it 'should make task responses be no longer completed' do
      expect do
        xhr :delete, :reset_activity, id: school_class, activity: {activity_id: activity}
      end.to change(TaskResponse.completed, :count).by (-6)
    end
    it 'should make unlocks be no longer hidden' do
      #it 'should make a task response be no longer hidden' do
      expect do
        xhr :delete, :reset_activity, id: school_class, activity: {activity_id: activity}
      end.to change(Unlock.where(hidden: true), :count).by(-3)
      #end.to change(TaskResponse.where(hidden: true), :count).by (-1)
    end
  end
end

#Tests to make sure nothing in other schools and classes are affected