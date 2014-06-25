FactoryGirl.define do

  factory :staff, class: Staff do
    sequence(:first_name) { |n| "First #{n}" }
    sequence(:last_name) { |n| "Last #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com" }
    password 'foobarbaz'
    password_confirmation { |u| u.password }

    factory :static_staff do
      first_name 'Static'
      last_name 'Staff'
      email 'thisemail@doesntexist.com'
    end

    ignore do
      school { School.first || FactoryGirl.create(:school) }
      school_class { school.school_classes.first || FactoryGirl.create(:school_class, :school => school) }
      curriculum { CurriculumPage.first || FactoryGirl.create(:curriculum_page) }
    end

    trait :teacher do
      after(:create) do |staff, evaluator|
        staff.becomes(User).add_role :teacher, evaluator.school
        staff.becomes(User).add_role :teacher, evaluator.school_class
      end
    end


    trait :school_admin do
      after(:create) do |staff, evaluator|
        staff.becomes(User).add_role :school_admin, evaluator.school
      end
    end

    trait :super_staff do
      after(:create) do |staff|
        staff.becomes(User).add_role :super_staff
      end
    end

    trait :curriculum_designer do
      after(:create) do |staff, evaluator|
        staff.becomes(User).add_role :curriculum_designer, evaluator.curriculum
      end
    end

    after(:create) { |staff| staff.confirm! }
  end
end