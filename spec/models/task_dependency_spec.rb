require 'spec_helper'

describe TaskDependency do
  let(:prerequisite){FactoryGirl.create(:assessment_task)}
  let(:dependant){FactoryGirl.create(:laplaya_task)}

  before do
    dependant.depend_on(prerequisite)
    @TaskDependency=dependant.task_dependencies.first
  end

  subject{@TaskDependency}

  it{should respond_to(:prerequisite)}
  it{should respond_to(:dependant)}
  it{should be_valid}

  describe "a dependeny between tasks in different modules" do
    let(:other_module){FactoryGirl.create(:module_page)}
    let(:other_activity){FactoryGirl.create(:activity_page, module_page:other_module)}
    before do
      other_module
      other_activity
      other_activity.tasks << prerequisite
    end
    it{should_not be_valid}
  end

end