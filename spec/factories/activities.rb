# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :activity_page, :class => ActivityPage do

    ignore do
      module_page { ModulePage.first || FactoryGirl.create(:module_page) }
    end

    sequence(:title) { |n| "SampleActivity #{n}" }

    student_body <<-eos
<h3> This is a test body for the student page of an activity! </h3>
Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute
irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
deserunt mollit anim id est laborum.
    eos

    teacher_body <<-eos
<h3> This is a test body for the teacher page of a activity! </h3>
Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute
<a href="/"> This is a test link that happens to be in the middle of Lorem ipsum</a>
irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
deserunt mollit anim id est laborum.
    eos

    after(:build) do |activity, evaluator|
      activity.page_id = evaluator.module_page.id
    end
  end
end
