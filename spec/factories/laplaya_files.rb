# Read about factories at https://github.com/thoughtbot/factory_girl
require 'erbalt'

FactoryGirl.define do
  sequence :file_name do |n|
    "Laplaya_File #{n}"
  end
  sequence :star_wars_file_name do |n|
    "Star Wars Laplaya_File #{n}"
  end
  factory :laplaya_file, :class => LaplayaFile do
    ignore do
      file_name_for_template { generate :file_name }
      notes_for_template { "Some notes for #{file_name_for_template}. \n:)" }
      project_template_file File.open("#{Rails.root}/lib/laplaya_test_files/testproj_project.xml.erb").read
      media_template_file File.open("#{Rails.root}/lib/laplaya_test_files/testproj_media.xml.erb").read
    end

    project { ErbalT::render_from_hash(project_template_file, {file_name: file_name_for_template, notes: notes_for_template}) }
    media { ErbalT::render_from_hash(media_template_file, {file_name: file_name_for_template}) }
    public { owner.nil? }

    trait :star_wars do
      ignore do
        file_name_for_template { generate :star_wars_file_name }
        notes_for_template { "Some notes for #{file_name_for_template}. \n:)" }
        project_template_file File.open("#{Rails.root}/lib/laplaya_test_files/starwars_project.xml.erb").read
        media_template_file File.open("#{Rails.root}/lib/laplaya_test_files/starwars_media.xml.erb").read
        owner nil
      end
    end

    factory :task_base_laplaya_file, class: TaskBaseLaplayaFile do
      ignore do
        laplaya_task { FactoryGirl.create(:laplaya_task, laplaya_file: false ) }
      end

      public false

      after(:build) do |laplaya_file, evaluator|
        laplaya_file.laplaya_task = evaluator.laplaya_task
      end
    end

    factory :task_completed_laplaya_file, class: TaskCompletedLaplayaFile do
      ignore do
        laplaya_task { FactoryGirl.create(:laplaya_task, laplaya_completed: false ) }
      end

      public false

      after(:build) do |laplaya_file, evaluator|
        laplaya_file.laplaya_task = evaluator.laplaya_task
      end
    end

    factory :project_base_laplaya_file, class: ProjectBaseLaplayaFile do
      ignore do
        module_page { FactoryGirl.create(:module_page, laplaya_file: false ) }
      end

      public false

      after(:build) do |laplaya_file, evaluator|
        laplaya_file.module_page = evaluator.module_page
      end
    end

    factory :sandbox_base_laplaya_file, class: SandboxBaseLaplayaFile do
      ignore do
        module_page { FactoryGirl.create(:module_page, laplaya_file: false ) }
      end

      public false

      after(:build) do |laplaya_file, evaluator|
        laplaya_file.module_page = evaluator.module_page
      end
    end

  end
end
