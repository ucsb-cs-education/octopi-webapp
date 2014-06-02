# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :module_page, :class => ModulePage do

    ignore do
      curriculum_page { CurriculumPage.first || FactoryGirl.create(:curriculum_page) }
    end

    sequence(:title) { |n| "SampleModule #{n}" }

    student_body <<-eos
<h3> This is a test body for the student page of a module! </h3>
Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute
irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
deserunt mollit anim id est laborum.
    eos

    teacher_body <<-eos
<h3> This is a test body for the teacher page of a module! </h3>
Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute
<a href="/"> This is a test link that happens to be in the middle of Lorem ipsum</a>
irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
deserunt mollit anim id est laborum.
    eos

    after(:build) do |module_page, evaluator|
      module_page.page_id = evaluator.curriculum_page.id
    end

  end
end
