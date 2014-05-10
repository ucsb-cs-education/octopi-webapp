class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/bryanrite/cancancan/wiki/Defining-Abilities

    #A non-signed in student (thus, any user) must be able to access all the school's names to select his/her to login
    can :index, School
    #A non-signed in student (thus, any user) must be able to access all student's logins to select his/her logins
    can :list_student_logins, Student

    alias_action :create, :read, :update, :destroy, :to => :crud
    alias_action :read, :update, :to => :read_update
    if user
      if user.class == User
        can :crud, User, :id => user

        if user.has_role? :global_admin
          can :manage, :all
          # The following rules are all implicit with :manage
          # can :change_school_name, :all
          # can :crud, :all
        else
          if user.has_role? :school_admin, :any
            schools = School.with_role(:school_admin, user)
            can :read_update, School, :id => schools.pluck(:id)
            can :crud, Student, :id => schools.to_a.map { |f| f.students.pluck(:id) }.flatten(1)
            can :crud, SchoolClass, :id => schools.to_a.map { |f| f.school_classes.pluck(:id) }.flatten(1)
            can :create, SchoolClass
            can :create, Student
          elsif user.has_role? :teacher, :any
            schools = School.with_role(:teacher, user)
            can :read, School, :id => schools.pluck(:id)
            can :crud, Student, :id => schools.to_a.map { |f| f.students.pluck(:id) }.flatten(1)
            can :read_update, SchoolClass, :id => SchoolClass.with_role(:teacher, user).pluck(:id)
            can :create, Student
          end
        end
      elsif user.class == Student
        can :crud, SnapFile, :id => SnapFile.with_role(:owner, user).pluck(:id)
        can :read, SnapFile, public: true
        can :create, SnapFile
        can :read, Student, :id => user
      end
    end
  end
end
