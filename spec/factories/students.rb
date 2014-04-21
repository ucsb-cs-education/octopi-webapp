FactoryGirl.define do

  factory :student do
    ignore do
      school { School.first || FactoryGirl.create(:school) }
      school_class { SchoolClass.first || FactoryGirl.create(:school_class) }
    end

    sequence(:name) { |n| "First #{n} Student" }
    sequence(:login_name) { |n| "student_#{n}_login" }
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