# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :laplaya_analysis_file do

    ignore do
      processor File.open("#{Rails.root}/lib/laplaya_test_files/analysis/sample_processor.js").read
      laplaya_task { FactoryGirl.create(:laplaya_task, laplaya_analysis: false) }
    end

    data { processor }

    after(:build) do |analysis_file, evaluator|
      analysis_file.laplaya_task = evaluator.laplaya_task
    end

  end
end
