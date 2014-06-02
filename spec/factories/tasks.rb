# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :laplaya_task, :class => LaplayaTask do

    ignore do
      activity_page { ActivityPage.first || FactoryGirl.create(:activity_page) }
    end

    sequence(:title) { |n| "SampleLaplayaTask #{n}" }

    student_body  <<-eos
<h3> This is a test body for the student page of a laplaya task! </h3>
Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute
irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
deserunt mollit anim id est laborum.
    eos

    teacher_body  <<-eos
<h3> This is a test body for the teacher page of a laplaya task! </h3>
Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute
<a href="/"> This is a test link that happens to be in the middle of Lorem ipsum</a>
irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
deserunt mollit anim id est laborum.
    eos

    after :create do |task, evaluator|
      FactoryGirl.create(:task_base_laplaya_file, laplaya_task: task)
    end

    after(:build) do |task, evaluator|
      task.page_id = evaluator.activity_page.id
    end

  end
end
