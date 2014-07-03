# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :curriculum_page, :class => CurriculumPage do
    sequence(:title) { |n| "SampleCurriculum #{n}" }

    student_body <<-eos
Test Content
    eos

    teacher_body <<-eos
Test Content
    eos

  end
end
