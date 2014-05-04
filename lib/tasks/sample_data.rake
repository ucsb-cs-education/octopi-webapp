namespace :db do
  desc "Fill database with sample data"
  task fullResetAndPopulate: :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    admin = FactoryGirl.create(:user, :global_admin, email: "global_admin@example.com")
    school = FactoryGirl.create(:school)
    school_admin = FactoryGirl.create(:user, :school_admin, email: "school_admin@example.com")
    teacher = FactoryGirl.create(:user, :teacher, school: school, email: "teacher@example.com")
    5.times do
      student = FactoryGirl.create(:student, school: school)
    end

    school2 = FactoryGirl.create(:school)
    2.times do
      FactoryGirl.create(:student, school: school2)
    end

    file = File.open("#{Rails.root}/lib/assets/snap_test_files/starwars.xml", 'r')
    contents = file.read
    file.close

    5.times do
      SnapFile.create(xml: contents, sample_file: true)
    end

    Student.first.add_role :owner, SnapFile.first
    Student.first.add_role :owner, SnapFile.find(2)
    Student.last.add_role :owner, SnapFile.first
    User.first.add_role :owner, SnapFile.first
    User.first.add_role :owner, SnapFile.find(3)

  end
end
