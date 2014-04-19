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

    #A student (thus, any user) must be able to access all the school's names to select his/her to login
    can :index, School
    alias_action :create, :read, :update, :destroy, :to => :crud

    cannot :change_school_name, :all
    if user
      can :crud, User, :id => user

      if user.has_role? :global_admin
        can :manage, :all
        # The following rules are all implicit with :manage
        # can :change_school_name, :all
        # can :crud, :all
      else
        if user.has_role? :school_admin, :any
          can :crud, School, :id => School.with_role(:school_admin, user).pluck(:id)
          can :crud, Student, :id => School.with_role(:school_admin, user).to_a.map { |f| f.students.pluck(:id) }.flatten(1)
          can :create, Student
        end

      end
    end
  end
end
