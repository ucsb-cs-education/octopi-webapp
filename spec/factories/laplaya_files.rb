# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :laplaya_file, :class => LaplayaFile do
    ignore do
      file = File.open("#{Rails.root}/lib/assets/laplaya_test_files/testproj.xml", 'r')
      testproj file.read
      file.close
      owner nil
    end

    project { testproj }
    public { owner.nil? }

    trait :star_wars do
      ignore do
        file = File.open("#{Rails.root}/lib/assets/laplaya_test_files/starwars.xml", 'r')
        starwars file.read
        file.close
      end
      project {starwars}
    end

    after(:create) do |laplaya_file, evaluator|
      if evaluator.owner
        evaluator.owner.add_role :owner, laplaya_file
      else
      end
    end

    factory :task_base_laplaya_file, class: TaskBaseLaplayaFile do
    end

  end
end
