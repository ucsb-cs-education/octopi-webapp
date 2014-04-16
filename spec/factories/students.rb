FactoryGirl.define do

  factory :student do
    ignore do
      school { School.first || FactoryGirl.create(:school) }
    end

    sequence(:name) { |n| "First #{n} Student" }
    password 'foobarbaz'
    password_confirmation { |u| u.password }

    factory :static_student do
      name 'Static Student Name'
    end

    after(:build) do |student, evaluator|
      student.school_id = evaluator.school.id
    end
  end
end