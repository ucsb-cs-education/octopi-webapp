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
    end

    sequence(:title) { |n| "SampleLaplayaTask #{n}" }

    student_body  <<-eos
Sample Content
    eos

    teacher_body  <<-eos
Sample Content
    eos

    after :create do |task, evaluator|
      FactoryGirl.create(:task_base_laplaya_file, laplaya_task: task)
    end

    after(:build) do |task, evaluator|
      task.page_id = evaluator.activity_page.id
    end

  end
end
