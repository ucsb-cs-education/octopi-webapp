# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :report_run_result do
    report_run nil
    laplaya_file nil
    json_results "MyText"
  end
end
