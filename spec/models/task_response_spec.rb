require 'spec_helper'

describe TaskResponse do
  let(:school_class) { FactoryGirl.create(:school_class) }
  let(:new_student) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }
  let(:top_task) { FactoryGirl.create(:assessment_task) }

  before do
    school_class
    new_student
    top_task
    @TaskResponse = AssessmentTaskResponse.create(task: top_task, school_class: school_class, student: new_student)
  end

  subject { @TaskResponse }

  # Basic attributes
  it { should respond_to(:task) }
  it { should respond_to(:student) }
  it { should respond_to(:school_class) }
  it { should be_valid }


  shared_examples 'a dependency relationship' do
    describe 'For a single model depending on a single task' do
      let(:bottom_task) { FactoryGirl.create(model_under_test, model_factory_params) }
      before do
        bottom_task.depend_on(top_task)
      end
      describe 'when dependencies are unlocked' do
        it 'should unlock a task response' do
          expect do
            @TaskResponse.update(completed: true)
          end.to change(method_of_unlock.unlocked, :count).by(1)
        end
        describe 'when the dependant task has no response' do
          it 'by creating a task response' do
            expect do
              @TaskResponse.update(completed: true)
            end.to change(method_of_unlock, :count).by(1)
          end
        end
        describe 'when the dependant task already has a response' do
          before do
            bottom_task.get_visibility_status_for(new_student, school_class)
          end
          it 'should unlock the dependant task' do
            @TaskResponse.update(completed: true)
            expect(method_of_unlock.find_by(owner => bottom_task, school_class: school_class, student: new_student).unlocked).to eq(true)
          end
          it 'should not create a new resp0nse' do
            expect do
              @TaskResponse.update(completed: true)
            end.to_not change(method_of_unlock, :count)
          end
        end
      end
    end

    describe 'For two models depending on a single task' do
      let(:bottom_task_1) { FactoryGirl.create(model_under_test, model_factory_params) }
      let(:bottom_task_2) { FactoryGirl.create(model_under_test, model_factory_params) }
      before do
        bottom_task_1.depend_on(top_task)
        bottom_task_2.depend_on(top_task)
      end
      describe 'when dependencies are unlocked' do
        it 'should unlock two task responses' do
          expect do
            @TaskResponse.update(completed: true)
          end.to change(method_of_unlock.unlocked, :count).by(2)
        end
        describe 'when the dependants do not yet have responses' do
          it 'should create two new task responses' do
            expect do
              @TaskResponse.update(completed: true)
            end.to change(method_of_unlock, :count).by(2)
          end
        end
        describe 'when the dependants already have responses' do
          before do
            bottom_task_1.get_visibility_status_for(new_student, school_class)
            bottom_task_2.get_visibility_status_for(new_student, school_class)
          end
          it 'should not create two new task responses' do
            expect do
              @TaskResponse.update(completed: true)
            end.to_not change(method_of_unlock, :count)
          end
          it 'should unlock the dependant tasks' do
            @TaskResponse.update(completed: true)
            expect(method_of_unlock.find_by(owner => bottom_task_1, school_class: school_class, student: new_student).unlocked).to eq(true)
          end
          it 'should unlock the dependant tasks' do
            @TaskResponse.update(completed: true)
            expect(method_of_unlock.find_by(owner => bottom_task_2, school_class: school_class, student: new_student).unlocked).to eq(true)
          end
        end
      end
    end

    describe 'For one model depending on two tasks' do
      let(:bottom_task) { FactoryGirl.create(model_under_test, model_factory_params) }
      let(:top_task_2) { FactoryGirl.create(:laplaya_task, activity_page: top_task.activity_page) }
      before do
        bottom_task.depend_on(top_task)
        bottom_task.depend_on(top_task_2)
        @TaskResponse2 = LaplayaTaskResponse.create(task: top_task_2, school_class: school_class, student: new_student)
      end

      describe "when only one of the prerequisite task's response unlocks dependencies" do
        it 'should not unlock a task response when only one is completed' do
          expect do
            @TaskResponse.update(completed: true)
          end.to_not change(method_of_unlock.unlocked, :count)
        end
        it 'should not unlock a task response when only one is completed' do
          expect do
            @TaskResponse2.update(completed: true)
          end.to_not change(method_of_unlock.unlocked, :count)
        end
      end

      describe "when both prerequisite tasks' responses unlock dependencies" do
        it 'should unlock one task response' do
          expect do
            @TaskResponse.update(completed: true)
            @TaskResponse2.update(completed: true)
          end.to change(method_of_unlock.unlocked, :count).by(1)
        end
        describe 'when the dependant task does not already have a response' do
          it 'should correctly unlock the shared dependant' do
            @TaskResponse.update(completed: true)
            @TaskResponse2.update(completed: true)
            expect(method_of_unlock.find_by(owner => bottom_task, school_class: school_class, student: new_student).unlocked).to eq(true)
          end
          it 'should create a new task responses' do
            expect do
              @TaskResponse.update(completed: true)
              @TaskResponse2.update(completed: true)
            end.to change(method_of_unlock, :count).by(1)
          end
          it 'should unlock a task response' do
            expect do
              @TaskResponse.update(completed: true)
              @TaskResponse2.update(completed: true)
            end.to change(method_of_unlock.unlocked, :count).by(1)
          end
        end
        describe 'when the dependant task alreasy has a response' do
          before do
            bottom_task.get_visibility_status_for(new_student, school_class)
          end
          it 'should correctly unlock the shared dependant' do
            @TaskResponse.update(completed: true)
            @TaskResponse2.update(completed: true)
            expect(method_of_unlock.find_by(owner => bottom_task, school_class: school_class, student: new_student).unlocked).to eq(true)
          end
          it 'should not create a new task response' do
            expect do
              @TaskResponse.update(completed: true)
              @TaskResponse2.update(completed: true)
            end.to_not change(method_of_unlock, :count)
          end
          it 'should unlock a task response' do
            expect do
              @TaskResponse.update(completed: true)
              @TaskResponse2.update(completed: true)
            end.to change(method_of_unlock.unlocked, :count).by(1)
          end
        end
      end
    end
  end

  describe 'An AssessmentTask to Task relationship' do
    let(:model_under_test) { :assessment_task }
    let(:model_factory_params) { {activity_page: top_task.activity_page} }
    let(:method_of_unlock) {TaskResponse}
    let(:owner){:task}
    it_behaves_like 'a dependency relationship'
  end

  describe 'A LaplayaTask to Task relationship' do
    let(:model_under_test) { :laplaya_task }
    let(:model_factory_params) { {activity_page: top_task.activity_page} }
    let(:method_of_unlock) {TaskResponse}
    let(:owner){:task}
    it_behaves_like 'a dependency relationship'
  end

  describe 'An Activity to Task relationship' do
    let(:model_under_test) { :activity_page }
    let(:model_factory_params) { {module_page: top_task.activity_page.module_page} }
    let(:method_of_unlock) {ActivityUnlock}
    let(:owner){:activity_page}
    it_behaves_like 'a dependency relationship'
  end

end