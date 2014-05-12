# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :snap_file, :class => 'SnapFile' do
    ignore do
      file = File.open("#{Rails.root}/lib/assets/snap_test_files/testproj.xml", 'r')
      testproj file.read
      file.close
      owner nil
    end

    project { testproj }
    public { owner.nil? }

    trait :star_wars do
      ignore do
        file = File.open("#{Rails.root}/lib/assets/snap_test_files/starwars.xml", 'r')
        starwars file.read
        file.close
      end
      project {starwars}
    end

    after(:build) do |snap_file, evaluator|
      if evaluator.owner
        evaluator.owner.add_role :owner, snap_file
      else
      end
    end

  end
end
