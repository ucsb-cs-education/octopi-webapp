# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :school do
    sequence(:name)  { |n| "School #{n}" }
    student_remote_access_allowed false
  end
end
