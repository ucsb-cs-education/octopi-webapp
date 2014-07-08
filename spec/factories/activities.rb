# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :activity_page, :class => ActivityPage do

    ignore do
      curriculum_id nil
      module_page do
        page = nil
        if curriculum_id.present?
          page = ModulePage.where(curriculum_id: curriculum_id).first
        end
        page || FactoryGirl.create(:module_page, curriculum_id: curriculum_id)
      end
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
