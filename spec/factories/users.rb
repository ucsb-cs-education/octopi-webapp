FactoryGirl.define do

  factory :user, class: User do
    sequence(:first_name) { |n| "First #{n}" }
    sequence(:last_name) { |n| "Last #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com" }
    password 'foobarbaz'
    password_confirmation { |u| u.password }

    factory :static_user do
      first_name 'Static'
      last_name 'User'
      email 'thisemail@doesntexist.com'
    end

    ignore do
      school { School.first || FactoryGirl.create(:school) }
      school_class { school.school_classes.first || FactoryGirl.create(:school_class, :school => school) }
    end

    trait :teacher do
      after(:create) do |user, evaluator|
        user.add_role :teacher, evaluator.school
        user.add_role :teacher, evaluator.school_class
      end
    end


    trait :school_admin do
      after(:create) do |user, evaluator|
        user.add_role :school_admin, evaluator.school
      end
    end

    trait :global_admin do
      after(:create) do |user|
        user.add_role :global_admin
      end
    end

    after(:create) { |user| user.confirm! }
  end
end