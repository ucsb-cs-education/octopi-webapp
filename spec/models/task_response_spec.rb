require 'spec_helper'

describe TaskResponse do
  let(:school_class) { FactoryGirl.create(:school_class) }
  let(:new_student) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }
  let(:top_task) { FactoryGirl.create(:assessment_task) }
  let(:unlock) { Unlock.create(unlockable: Task.first, school_class: school_class, student: new_student, hidden: false) }

  before do
    school_class
    new_student
    top_task
    unlock
    @TaskResponse = TaskResponse.create(task: top_task, school_class: school_class, student: new_student)
  end

  subject { @TaskResponse }

  # Basic attributes
  it { should respond_to(:task) }
  it { should respond_to(:student) }
  it { should respond_to(:school_class) }
  it { should be_valid }

  describe "when its task is not unlocked" do
    before do
      Unlock.find_by(unlockable: top_task, school_class: school_class, student: new_student).delete
    end
    it{should_not be_valid}
  end

  shared_examples "a dependency relationship" do
    describe "For a single model depending on a single task" do
      let(:bottom_task) { FactoryGirl.create(model_under_test) }
      before do
        bottom_task.depend_on(top_task)
      end
      describe "when dependencies are unlocked" do
        it "should create an unlock" do
          expect do
            @TaskResponse.update_attribute(:completed, true)
            @TaskResponse.unlock_dependencies
          end.to change(Unlock, :count).by(1)
        end
        describe "by creating a new unlock" do
          before do
            @TaskResponse.update_attribute(:completed, true)
            @TaskResponse.unlock_dependencies
          end
          it "should unlock the dependant task" do
            expect(Unlock.find_by(unlockable: bottom_task, school_class: school_class, student: new_student)).to be_a(Unlock)
          end
        end
      end
    end

    describe "For two models depending on a single task" do
      let(:bottom_task_1) { FactoryGirl.create(model_under_test) }
      let(:bottom_task_2) { FactoryGirl.create(model_under_test) }
      before do
        bottom_task_1.depend_on(top_task)
        bottom_task_2.depend_on(top_task)
      end
      describe "when dependencies are unlocked" do
        it "should create two unlocks" do
          expect do
            @TaskResponse.update_attribute(:completed, true)
            @TaskResponse.unlock_dependencies
          end.to change(Unlock, :count).by(2)
        end
        describe "by creating new unlocks" do
          before do
            @TaskResponse.update_attribute(:completed, true)
            @TaskResponse.unlock_dependencies
          end
          it "should unlock the dependant tasks" do
            expect(Unlock.find_by(unlockable: bottom_task_1, school_class: school_class, student: new_student)).to be_a(Unlock)
            expect(Unlock.find_by(unlockable: bottom_task_2, school_class: school_class, student: new_student)).to be_a(Unlock)
          end
        end
      end
    end

    describe "For one model depending on two tasks" do
      let(:bottom_task) { FactoryGirl.create(model_under_test) }
      let(:top_task_2) { FactoryGirl.create(:laplaya_task) }
      let(:unlock_2) { Unlock.create(unlockable: LaplayaTask.first, school_class: school_class, student: new_student, hidden: false) }
      before do
        unlock_2
        bottom_task.depend_on(top_task)
        bottom_task.depend_on(top_task_2)
        @TaskResponse2 = TaskResponse.create(task: top_task_2, school_class: school_class, student: new_student)
      end

      describe "when only one of the prerequisite task's response unlocks dependencies" do
        it "should not create an unlock from one" do
          expect do
            @TaskResponse.update_attribute(:completed, true)
            @TaskResponse.unlock_dependencies
          end.to change(Unlock, :count).by(0)
        end
        it "should not create an unlock from the other" do
          expect do
            @TaskResponse2.update_attribute(:completed, true)
            @TaskResponse2.unlock_dependencies
          end.to change(Unlock, :count).by(0)
        end
      end

      describe "when both prerequisite tasks' responses unlock dependencies" do
        it "should create one unlock" do
          expect do
            @TaskResponse.update_attribute(:completed, true)
            @TaskResponse.unlock_dependencies
            @TaskResponse2.update_attribute(:completed, true)
            @TaskResponse2.unlock_dependencies
          end.to change(Unlock, :count).by(1)
        end
        describe "by creating a new unlock" do
          before do
            @TaskResponse.update_attribute(:completed, true)
            @TaskResponse.unlock_dependencies
            @TaskResponse2.update_attribute(:completed, true)
            @TaskResponse2.unlock_dependencies
          end
          it "should correctly unlock the shared dependant" do
            expect(Unlock.find_by(unlockable: bottom_task, school_class: school_class, student: new_student)).to be_a(Unlock)
          end
        end
      end
    end
  end

  describe "Finding the relevant unlock" do
    let(:locked_task) { FactoryGirl.create(:assessment_task) }
    before do
      @TaskResponseWithoutUnlock = TaskResponse.create(task: locked_task, school_class: school_class, student: new_student)
    end
    it "should return a lock when the unlock exists" do
      expect(@TaskResponse.find_unlock).to be_a(Unlock)
    end
    it "should return nil when the unlock does not exist" do
      expect(@TaskResponseWithoutUnlock.find_unlock).to eq(nil)
    end
  end

  describe "An AssessmentTask to Task relationship" do
    let(:model_under_test){:assessment_task}
    it_behaves_like "a dependency relationship"
  end

  describe "A LaplayaTask to Task relationship" do
    let(:model_under_test){:laplaya_task}
    it_behaves_like "a dependency relationship"
  end

  describe "An Activity to Task relationship" do
    let(:model_under_test){:activity_page}
    it_behaves_like "a dependency relationship"
  end

end