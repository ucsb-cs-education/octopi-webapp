# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :report_module_option, :class => 'ReportModuleOptions' do
    report nil
    module_page nil
    include_sandbox false
    include_project false
  end
end
