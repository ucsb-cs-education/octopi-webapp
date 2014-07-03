# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :assessment_task, :class => AssessmentTask do

    ignore do
      activity_page { ActivityPage.first || FactoryGirl.create(:activity_page) }
    end

    sequence(:title) { |n| "SampleAssessmentTask #{n}" }

    student_body  <<-eos
Test Content
    eos

    teacher_body  <<-eos
Test Content
    eos

    after :create do |task, evaluator|
      #FactoryGirl.create(:assessment_question, assessment_task: task)
    end

    after(:build) do |task, evaluator|
      task.page_id = evaluator.activity_page.id
    end

  end
end
