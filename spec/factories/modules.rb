# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :module_page, :class => ModulePage do

    ignore do
      curriculum_id nil
      module_page do
        page = nil
        if curriculum_id.present?
          page = ModulePage.where(curriculum_id: curriculum_id).first
        end
        page || FactoryGirl.create(:module_page, curriculum_id: curriculum_id)
      end
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
