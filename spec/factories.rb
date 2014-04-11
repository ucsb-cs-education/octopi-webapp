FactoryGirl.define do

  factory :static_user, class: User do
    first_name 'Static'
    last_name 'User'
    email 'thisemail@doesntexist.com'
    password 'foobarbaz'
    password_confirmation 'foobarbaz'

    factory :user do
      sequence(:first_name) { |n| 'Person #{n}' }
      sequence(:last_name) { |n| 'Last #{n}' }
      sequence(:email) { |n| 'person_#{n}@example.com' }
    end
    after(:create) { |user| user.confirm! }
  end

  factory :micropost do
    content 'Lorem ipsum'
    user
  end
end