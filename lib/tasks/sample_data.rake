namespace :db do
  desc "Fill database with sample data"
  task fullResetAndPopulate: ['db:drop', 'db:create', 'db:migrate'] do
    admin = FactoryGirl.create(:staff, :super_staff, email: "super_staff@example.com")
    school = FactoryGirl.create(:school)
    school_admin = FactoryGirl.create(:staff, :school_admin, email: "school_admin@example.com")
    teacher = FactoryGirl.create(:staff, :teacher, school: school, email: "teacher@example.com")
    5.times do
      student = FactoryGirl.create(:student, school: school)
    end

    school2 = FactoryGirl.create(:school)
    2.times do
      FactoryGirl.create(:student, school: school2)
    end

    a = FactoryGirl.create(:laplaya_file, owner: Student.first)

    Staff.first.add_role :owner, a
    Student.last.add_role :owner, a


    2.times do
      puts "Creating Curriculum Page and children..."
      a = FactoryGirl.create(:curriculum_page)
      2.times do
        b = FactoryGirl.create(:module_page, curriculum_page: a)
        2.times do
          c = FactoryGirl.create(:activity_page, module_page: b)
          2.times do
            d = FactoryGirl.create(:laplaya_task, activity_page: c)
          end
          2.times do
            e = FactoryGirl.create(:assessment_task, activity_page: c)
            2.times do
              f = FactoryGirl.create(:assessment_question, assessment_task: e)
            end
          end
        end
      end
    end

    curriculum_designer = FactoryGirl.create(:staff, :curriculum_designer, curriculum: CurriculumPage.first, email: "curriculum_designer@example.com")
    FactoryGirl.create(:laplaya_file, :star_wars, owner: Student.first)
    FactoryGirl.create(:laplaya_file, owner: Staff.first)
    FactoryGirl.create(:laplaya_file, owner: Student.offset(1).first, public: true)

    FactoryGirl.create(:laplaya_file, :star_wars, owner: curriculum_designer)
    FactoryGirl.create(:laplaya_file, :star_wars, owner: curriculum_designer)
    FactoryGirl.create(:laplaya_file, :star_wars, owner: admin)

    School.first.curriculum_pages << CurriculumPage.first
    School.first.school_classes.first.module_pages << CurriculumPage.first.module_pages.first

    Task.find(2).depend_on(Task.find(1))
    Task.find(3).depend_on(Task.find(1))
    Task.find(4).depend_on(Task.find(2))
    Task.find(4).depend_on(Task.find(3))
    Task.find(5).depend_on(Task.find(4))
    ActivityPage.find(4).depend_on(Task.find(4))

    starwars_task = FactoryGirl.create(:laplaya_task, activity_page: ActivityPage.first, laplaya_file: false)
    FactoryGirl.create(:task_base_laplaya_file, :star_wars, note: 'Made by Calixtemayoraz', laplaya_task: starwars_task)

  end
end
