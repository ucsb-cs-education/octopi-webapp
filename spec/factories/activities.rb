# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :activity_page, :class => ActivityPage do

    ignore do
      module_page { ModulePage.first || FactoryGirl.create(:module_page) }
    end

    sequence(:title) { |n| "SampleActivity #{n}" }

    student_body <<-eos
Test Content
    eos

    teacher_body <<-eos
Test Content
    eos

    after(:build) do |activity, evaluator|
      activity.page_id = evaluator.module_page.id
    end
  end
end
