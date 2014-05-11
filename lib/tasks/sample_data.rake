namespace :db do
  desc "Fill database with sample data"
  task fullResetAndPopulate: ['db:drop', 'db:create', 'db:migrate'] do
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

    a = FactoryGirl.create(:snap_file, owner: Student.first)

    User.first.add_role :owner, a
    Student.last.add_role :owner, a

    FactoryGirl.create(:snap_file, :star_wars, owner: Student.first)
    FactoryGirl.create(:snap_file, owner: User.first)
    FactoryGirl.create(:snap_file, owner: Student.find(2), public: true)



  end
end
