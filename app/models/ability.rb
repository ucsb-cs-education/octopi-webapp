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

    can :read, SnapFile, public: true

    alias_action :create, :read, :update, :destroy, :to => :crud
    alias_action :read, :update, :to => :read_update
    if user
      can :create_public_snap_files, SnapFile

      files = SnapFile.with_role(:owner, user).pluck(:id)
      can :crud, SnapFile, :id => files
      can :create, SnapFile

      if user.class == User
        can :crud, User, :id => user

        if user.has_role? :global_admin
          can :manage, :all
          # The following rules are all implicit with :manage
          # can :change_school_name, :all
          # can :crud, :all
        else
          if user.has_role? :school_admin, :any
            schools = School.with_role(:school_admin, user).pluck(:id)
            can :read_update, School, :id => schools

            can :crud, Student, :id => Student.where(school_id: schools).pluck(:id)
            can :create, Student

            can :crud, SchoolClass, :id => School.where(school_id: schools).pluck(:id)
            can :create, SchoolClass

          elsif user.has_role? :teacher, :any
            schools = School.with_role(:teacher, user).pluck(:id)
            can :read, School, :id => schools
            can :read, Student, :id => Student.where(school_id: schools.pluck(:id)).pluck(:id)

            school_classes = SchoolClass.with_role(:teacher, user).pluck(:id)
            can :read_update, SchoolClass, :id => school_classes
            can :crud, Student, :id => Student.joins(:school_classes).where(school_classes: {id: school_classes}).distinct.pluck(:id)

            can :create, Student
          end
        end
      elsif user.class == Student
        can :read, Student, id: user
      end
    end
  end
end
