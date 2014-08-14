require 'spec_helper'

describe StudentPortal::PagesController, type: :controller do
  let(:school_class) { FactoryGirl.create(:school_class) }
  let(:new_student) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }
  let(:prerequisite_task) { FactoryGirl.create(:assessment_task) }
  let(:dependant_task) { FactoryGirl.create(:assessment_task, activity_page: task.activity_page) }
  let(:dependant_activity) { FactoryGirl.create(:activity_page, module_page: task.activity_page.module_page) }


  before(:each) do
    school_class
    school_class.module_pages << task.activity_page.module_page
    new_student
    sign_in_as_student(new_student)
    task.depend_on(prerequisite_task)
  end

  describe 'Assessment Response Method' do
    let(:task) { FactoryGirl.create(:assessment_task) }
    let(:method_symbol) { :assessment_response }
    let(:params_name) { :assessment_task_response }

    describe 'Attempting to respond for a locked task' do
      before do
        AssessmentTaskResponse.create(school_class: school_class, student: new_student, task: task, unlocked: false)
      end

      it 'should not complete a task response' do
        expect do
          xhr :post, method_symbol, id: task.id, params_name => {
              school_class: school_class,
              student: new_student,
              task: task}
        end.to_not change(TaskResponse.completed, :count)
      end

      it 'should respond with 400' do
        xhr :post, method_symbol, id: task.id, params_name => {
            school_class: school_class,
            student: new_student}
        expect(response.status).to eq(400)
      end
    end

    describe 'Responding for a correctly unlocked task' do
      before do
        AssessmentTaskResponse.create(school_class: school_class, student: new_student, task: task, unlocked: true)
      end

      it 'should not create a new task response' do
        expect do
          xhr :post, method_symbol, id: task.id, params_name => {
              school_class: school_class,
              student: new_student,
              task: task}
        end.to_not change(TaskResponse, :count)
      end

      it 'should complete a task response' do
        expect do
          xhr :post, method_symbol, id: task.id, params_name => {
              school_class: school_class,
              student: new_student,
              task: task}
        end.to change(TaskResponse.completed, :count).by(1)
      end

      it 'should respond with 302' do
        xhr :post, method_symbol, id: task.id, params_name => {
            school_class: school_class,
            student: new_student}
        expect(response.status).to eq(302)
      end

      describe 'after the page has been viewed' do
        before do
          get :assessment_task, id: task.id
        end
        describe 'that has a dependency' do
          describe 'that is a task dependant' do

            before do
              dependant_task.depend_on(task)
            end

            it 'should create a new task response if none exists' do
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to change(TaskResponse, :count).by(1)
            end

            it 'should not create a new task response if one already exists' do
              AssessmentTaskResponse.create(school_class: school_class, student: new_student, task: dependant_task, unlocked: false)
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to_not change(TaskResponse, :count)
            end

            it 'should unlock a task response if the task response does not already exist' do
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to change(TaskResponse.unlocked, :count).by(1)
            end

            it 'should unlock a task response if the task response already exists' do
              AssessmentTaskResponse.create(school_class: school_class, student: new_student, task: dependant_task, unlocked: false)
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to change(TaskResponse.unlocked, :count).by(1)
            end

            it 'should respond with 302' do
              xhr :post, method_symbol, id: task.id, params_name => {
                  school_class: school_class,
                  student: new_student}
              expect(response.status).to eq(302)
            end
          end
          describe 'that is an activity dependant' do

            before do
              dependant_activity.depend_on(task)
            end

            it 'should not create a new task response' do
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to_not change(TaskResponse, :count)
            end

            it 'should create an activity unlock if none exists' do
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to change(ActivityUnlock, :count).by(1)
            end

            it 'should not create an activity unlock if one already exists' do
              ActivityUnlock.create(school_class: school_class, student: new_student, activity_page: dependant_activity, unlocked: false)
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to_not change(ActivityUnlock, :count)
            end

            it 'should unlock an activity unlock if the activity unlock already exists' do
              ActivityUnlock.create(school_class: school_class, student: new_student, activity_page: dependant_activity, unlocked: false)
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to change(ActivityUnlock.unlocked, :count).by(1)
            end

            it 'should unlock an activity unlock if the activity unlock does not already exist' do
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to change(ActivityUnlock.unlocked, :count).by(1)
            end

            it 'should respond with 302' do
              xhr :post, method_symbol, id: task.id, params_name => {
                  school_class: school_class,
                  student: new_student}
              expect(response.status).to eq(302)
            end
          end
        end
      end
    end
  end

  describe 'Laplaya Task Response Method' do
    let(:task) { FactoryGirl.create(:laplaya_task) }
    let(:method_symbol) { :laplaya_task_response }
    let(:params_name) { :laplaya_task_response }

    describe 'attempting to get a locked task' do
      it 'should create a new task response' do
        expect do
          get :laplaya_task, id: task.id
        end.to change(TaskResponse, :count).by(1)
      end

      it 'should respond with 302' do
        get :laplaya_task, id: task.id
        expect(response.status).to eq(302)
      end
    end

    describe 'Attempting to respond for a locked task' do
      before do
        LaplayaTaskResponse.create(school_class: school_class, student: new_student, task: task, unlocked: false)
      end
      it 'should not complete a task response' do
        expect do
          xhr :post, method_symbol, id: task.id, params_name => {
              school_class: school_class,
              student: new_student,
              task: task}
        end.to_not change(TaskResponse.completed, :count)
      end

      it 'should respond with 400' do
        xhr :post, method_symbol, id: task.id, params_name => {
            school_class: school_class,
            student: new_student}
        expect(response.status).to eq(400)
      end
    end

    describe 'Responding for a correctly unlocked task' do
      before do
        LaplayaTaskResponse.create(school_class: school_class, student: new_student, task: task, unlocked: true)
      end

      it 'should not create a new task response' do
        expect do
          xhr :post, method_symbol, id: task.id, params_name => {
              school_class: school_class,
              student: new_student,
              task: task}
        end.to_not change(TaskResponse, :count)
      end

      it 'should completed a task response' do
        expect do
          xhr :post, method_symbol, id: task.id, params_name => {
              school_class: school_class,
              student: new_student,
              task: task}
        end.to change(TaskResponse.completed, :count).by(1)
      end

      it 'should respond with 302' do
        xhr :post, method_symbol, id: task.id, params_name => {
            school_class: school_class,
            student: new_student}
        expect(response.status).to eq(302)
      end

      it 'should not create a new task response when GET' do
        expect do
          get :laplaya_task, id: task.id
        end.to_not change(TaskResponse, :count)
      end
      describe 'after the page has been viewed' do
        before do
          LaplayaTask.find(task.id).get_visibility_status_for(new_student, school_class)
          LaplayaTask.find(task.id).activity_page.get_visibility_status_for(new_student,school_class)
        end
        describe 'that has a dependency' do
          describe 'that is a task dependant' do

            before do
              dependant_task.depend_on(task)
            end

            it 'should create a new task response if none exists' do
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to change(TaskResponse, :count).by(1)
            end

            it 'should not create a new task response if one already exists' do
              LaplayaTaskResponse.create(school_class: school_class, student: new_student, task: dependant_task, unlocked: false)
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to_not change(TaskResponse, :count)
            end

            it 'should unlock a task response if the task response does not already exist' do
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to change(TaskResponse.unlocked, :count).by(1)
            end

            it 'should unlock a task response if the task response already exists' do
              LaplayaTaskResponse.create(school_class: school_class, student: new_student, task: dependant_task, unlocked: false)
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to change(TaskResponse.unlocked, :count).by(1)
            end

            it 'should respond with 302' do
              xhr :post, method_symbol, id: task.id, params_name => {
                  school_class: school_class,
                  student: new_student}
              expect(response.status).to eq(302)
            end
          end
          describe 'that is an activity dependant' do

            before do
              dependant_activity.depend_on(task)
            end

            it 'should not create a new task response' do
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to_not change(TaskResponse, :count)
            end

            it 'should create an activity unlock if none exists' do
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to change(ActivityUnlock, :count).by(1)
            end

            it 'should not create an activity unlock if one already exists' do
              ActivityUnlock.create(school_class: school_class, student: new_student, activity_page: dependant_activity, unlocked: false)
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to_not change(ActivityUnlock, :count)
            end

            it 'should unlock an activity unlock if the activity unlock already exists' do
              ActivityUnlock.create(school_class: school_class, student: new_student, activity_page: dependant_activity, unlocked: false)
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to change(ActivityUnlock.unlocked, :count).by(1)
            end

            it 'should unlock an activity unlock if the activity unlock does not already exist' do
              expect do
                xhr :post, method_symbol, id: task.id, params_name => {
                    school_class: school_class,
                    student: new_student,
                    task: task}
              end.to change(ActivityUnlock.unlocked, :count).by(1)
            end

            it 'should respond with 302' do
              xhr :post, method_symbol, id: task.id, params_name => {
                  school_class: school_class,
                  student: new_student}
              expect(response.status).to eq(302)
            end
          end
        end
      end
    end
  end

end