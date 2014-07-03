# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :module_page, :class => ModulePage do

    ignore do
      curriculum_page { CurriculumPage.first || FactoryGirl.create(:curriculum_page) }
    end

    sequence(:title) { |n| "SampleModule #{n}" }

    student_body <<-eos
Test Content
    eos

    teacher_body <<-eos
Test Content
    eos

    after(:build) do |module_page, evaluator|
      module_page.page_id = evaluator.curriculum_page.id
    end

  end
end
