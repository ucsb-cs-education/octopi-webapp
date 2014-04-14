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
    end

    trait :teacher do
      after(:create) do |user, evaluator|
        user.add_role :teacher, evaluator.school
      end
    end


    trait :school_admin do
      after(:create) do |user, evaluator|
        user.add_role :school_admin, evaluator.school
      end
    end

    after(:create) { |user| user.confirm! }
  end
end