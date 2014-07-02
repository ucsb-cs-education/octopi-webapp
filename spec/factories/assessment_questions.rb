# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :assessment_question, :class => AssessmentQuestion do

    ignore do
      assessment_task { AssessmentTask.first || FactoryGirl.create(:assessment_task) }
    end

    sequence(:title) { |n| "SampleQuestion #{n}" }

    question_body <<-eos

    eos


    answers '[{"text":"<p></p>","correct":true}]' #'[{"text":"<p>This is a header</p><p>And I am above!</p>","correct":false},{"text":"<p>This is a toaster. <img data-cke-saved-src=\"http://www.ohgizmo.com/wp-content/uploads/2010/05/kenwood_toaster.jpg\" src=\"http://www.ohgizmo.com/wp-content/uploads/2010/05/kenwood_toaster.jpg\" style=\"height:80px; width:80px\"></p><p><br></p>","correct":true},{"text":"<p>You can trust me.</p>","correct":false},{"text":"<p>Whales can fly.</p>","correct":false}]'
    question_type "singleAnswer"

    after(:build) do |assessment_question, evaluator|
      assessment_question.assessment_task_id = evaluator.assessment_task.id
    end
  end
end
