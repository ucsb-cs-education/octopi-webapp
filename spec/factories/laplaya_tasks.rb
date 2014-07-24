# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :laplaya_task, :class => LaplayaTask do

    ignore do
      curriculum_id nil
      activity_page do
        page = nil
        if curriculum_id.present?
          page = ActivityPage.where(curriculum_id: curriculum_id).first
        end
        page || FactoryGirl.create(:activity_page, curriculum_id: curriculum_id)
      end
      #set to false if you don't want it to create a laplaya_file
      laplaya_file true
      laplaya_analysis true
    end

    sequence(:title) { |n| "SampleLaplayaTask #{n}" }

    student_body <<-eos
<h1>This is a test body for the student page of a laplaya task.</h1>

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure
dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    eos

    teacher_body <<-eos
This is a test body for the teacher page of a laplaya task!

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure
dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    eos

    after :create do |task, evaluator|
      FactoryGirl.create(:task_base_laplaya_file, laplaya_task: task) if evaluator.laplaya_file
      FactoryGirl.create(:laplaya_analysis_file, laplaya_task: task) if evaluator.laplaya_analysis
    end

    after(:build) do |task, evaluator|
      task.page_id = evaluator.activity_page.id
    end

  end
end
