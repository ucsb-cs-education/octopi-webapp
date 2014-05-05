FactoryGirl.define do

  factory :student do
    ignore do
      school { School.first || FactoryGirl.create(:school) }
      school_class { school.school_classes.first || FactoryGirl.create(:school_class, :school => school) }
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
      student.school_classes << evaluator.school_class
    end
  end
end