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

  describe "A single task depending on a single task" do
    let(:bottom_task) { FactoryGirl.create(:laplaya_task) }
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
          expect(Unlock.find_by(unlockable:bottom_task,school_class:school_class,student:new_student)).to_not eq(nil)
        end
      end
    end
  end

end