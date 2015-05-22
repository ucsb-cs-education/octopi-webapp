# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :report do
    name "MyString"
    description "MyText"
    code "MyText"
  end
end
