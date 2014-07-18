require 'spec_helper'

describe TaskDependency do
  let(:prerequisite) { FactoryGirl.create(:assessment_task) }
  let(:dependant) { FactoryGirl.create(:activity_page) }
  let(:another_activity) { FactoryGirl.create(:activity_page) }

  before do
    dependant.module_page.activity_pages << another_activity
    another_activity.tasks << prerequisite
    dependant.depend_on(prerequisite)
    @ActivityDependency=dependant.activity_dependencies.first
  end

  subject { @ActivityDependency }

  it { should respond_to(:task_prerequisite) }
  it { should respond_to(:activity_dependant) }
  it { should be_valid }

  describe "a dependeny between an activity and a task in different modules" do
    let(:other_module) { FactoryGirl.create(:module_page) }
    let(:other_activity) { FactoryGirl.create(:activity_page, module_page: other_module) }
    before do
      other_module
      other_activity
      other_activity.tasks << prerequisite
    end
    it { should_not be_valid }
  end

  describe "a dependency between an activity and a task within itself" do
    before do
      dependant.tasks << prerequisite
    end
    it { should_not be_valid }
  end
end