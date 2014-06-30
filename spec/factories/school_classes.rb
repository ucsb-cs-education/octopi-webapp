 # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :school_class do

  ignore do
    school { School.first || FactoryGirl.create(:school) }
  end

  sequence(:name) { |n| "Class #{n}" }

  after(:build) do |school_class, evaluator|
    school_class.school_id = evaluator.school.id
  end

  end
end
