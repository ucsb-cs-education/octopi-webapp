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

    can :show, LaplayaFile, public: true

    alias_action :create, :read, :update, :destroy, :to => :crud
    alias_action :create, :show, :update, :destroy, :to => :csud #crud without index
    alias_action :read, :update, :to => :read_update
    if user
      can :create_public_laplaya_files, LaplayaFile

      files = LaplayaFile.with_role(:owner, user).pluck(:id)
      can :crud, LaplayaFile, :id => files
      can :create, LaplayaFile

      if user.class == Staff
        #All users can edit themselves
        can :crud, Staff, :id => user.id
        can :read, ActiveAdmin::Page, :name => "Dashboard"

        cannot :update, Staff.with_role(:super_staff).where.not(id: user)
        cannot :destroy, Staff.with_role(:super_staff).where.not(id: user)
        if user.has_role? :super_staff
          super_staff(user)
        else
          school_admin(user) if user.has_role? :school_admin, :any
          teacher(user) if user.has_role? :teacher, :any
        end
      elsif user.class == Student
        student(user)

      end
    end
  end

  def curriculum_designer(user)
  end

  def super_staff(user)
    can :manage, :all
  end

  def school_admin(user)
    schools = School.with_role(:school_admin, user)
    school_ids = schools.pluck(:id)
    can :read_update, School, :id => school_ids

    can :crud, Student, :id => Student.where(school_id: school_ids).pluck(:id)
    can :create, Student

    can :crud, SchoolClass, :id => SchoolClass.where(school_id: school_ids).pluck(:id)
    can :create, SchoolClass

    can :crud, Staff, :id => schools.map { |school| school.users }.flatten(1).map { |x| x.id }.uniq
    can :see_user_admin_menu
  end

  def teacher(user)
    schools = School.with_role(:teacher, user).pluck(:id)
    can :read, School, :id => schools
    can :read, Student, :id => Student.where(school_id: schools).pluck(:id)

    school_classes = SchoolClass.with_role(:teacher, user).pluck(:id)
    can :read_update, SchoolClass, :id => school_classes
    can :crud, Student, :id => Student.joins(:school_classes).where(school_classes: {id: school_classes}).distinct.pluck(:id)

    can :create, Student
  end

  def student(user)
    can :read, Student, id: user
  end


end
