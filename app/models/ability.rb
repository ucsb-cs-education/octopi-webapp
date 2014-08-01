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
      can :crud, LaplayaFile, id: files
      can :crud, LaplayaFile, user_id: user.id
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
          curriculum_designer(user) if user.has_role? :curriculum_designer, :any
        end
      elsif user.class == Student
        student(user)

      end
    end
  end

  def curriculum_designer(user)
    page_ids = CurriculumPage.with_role(:curriculum_designer, user).pluck(:id)
    can [:crud, :add_designer, :show_sandbox_file, :show_project_file], Page, :curriculum_id => page_ids
    can [:crud, :clone, :clone_completed,
         :update_laplaya_analysis_file, :get_laplaya_analysis_file,
         :show_completed_file, :show_base_file], Task, :curriculum_id => page_ids
    can :crud, AssessmentQuestion, :curriculum_id => page_ids
    can [:show, :update], LaplayaFile, {:curriculum_id => page_ids, :type => %w(TaskBaseLaplayaFile SandboxBaseLaplayaFile ProjectBaseLaplayaFile TaskCompletedLaplayaFile)}
    can [:create, :clone_project, :clone_sandbox], ModulePage
    can :create, ActivityPage
    can :create, LaplayaTask
    can :create, OfflineTask
    can :create, AssessmentQuestion
    can :create, AssessmentTask
    can :see_developer_view, LaplayaFile
  end

  def super_staff(user)
    can :manage, :all
  end

  def school_admin(user)
    schools = School.with_role(:school_admin, user)
    school_ids = schools.pluck(:id)
    cannot :read, School, :id => School.pluck(:id) - schools
    can [:read_update, :add_teacher, :add_school_admin], School, id: school_ids

    can :crud, Student, :id => Student.where(school_id: school_ids).pluck(:id)
    can :create, Student

    school_classes = SchoolClass.where(school_id: school_ids)
    school_classes_ids = school_classes.pluck(:id)
    can [:crud, :add_class_teacher, :add_new_student, :add_student], SchoolClass, id: school_classes_ids
    can :create, SchoolClass

    staff_school_roles = Role.where(name: [:teacher, :school_admin], resource_type: 'School', resource_id: school_ids)
    staff_school_class_roles = Role.where(name: [:teacher], resource_type: 'SchoolClass', resource_id: school_classes_ids)
    roles = []
    [staff_school_roles, staff_school_class_roles].each do |staff_roles|
      roles.push *(staff_roles.map{|x| {name: x.name, resource: x.resource}})
    end
    staff_ids = []
    roles.each do |role|
      staff_ids.push *(Staff.with_role(role[:name], role[:resource]).pluck(:id))
    end
    staff_ids.uniq!
    can :crud, Staff, id: staff_ids
    can :create, Staff

    page_ids = CurriculumPage.all.pluck(:id)
    can :read, Page, :curriculum_id => page_ids
    can :read, Task, :curriculum_id => page_ids
    can :read, AssessmentQuestion, :curriculum_id => page_ids
    can :read, LaplayaFile, {:curriculum_id => page_ids, :type => "TaskBaseLaplayaFile"}
    can :see_user_admin_menu
  end

  def teacher(user)
    school_classes = SchoolClass.with_role(:teacher, user).pluck(:id)
    school_classes_teacher = SchoolClass.with_role(:teacher, user).pluck(:school_id)
    schools_teacher = School.with_role(:teacher, user).pluck(:id)
    if School.with_role(:teacher, user) != []
      cannot :read, School, :id => School.pluck(:id) - schools_teacher
      can :read, School, :id => schools_teacher
      can :crud, Student, :id => Student.where(school_id: schools_teacher).pluck(:id)
      can [:read_update, :add_new_student, :add_student], SchoolClass, :id => SchoolClass.where(school_id: schools_teacher).pluck(:id)
    else
      cannot :read, School, :id => School.pluck(:id) - school_classes_teacher
      can :read, School, :id => school_classes_teacher
      can [:read, :update], Student, :id=> Student.where(school_id: school_classes_teacher).pluck(:id)
      can :crud, Student, :id => SchoolClass.with_role(:teacher, user).map{|school_class| school_class.students.map {
          |student| student.id}.flatten(1)}.flatten(1).uniq
      can [:read_update, :add_new_student, :add_student], SchoolClass, :id => school_classes
    end
    page_ids = CurriculumPage.all.pluck(:id)
    can :read, Page, :curriculum_id => page_ids
    can :read, Task, :curriculum_id => page_ids
    can :read, AssessmentQuestion, :curriculum_id => page_ids
    can :read, LaplayaFile, {:curriculum_id => page_ids, :type => "TaskBaseLaplayaFile"}
    can :create, Student
  end

  def student(user)
    can :read, Student, id: user
    if (user.respond_to? :current_class) && (user.current_class.present?)
      can :show, LaplayaFile, id: SandboxBaseLaplayaFile.where(parent_id: user.current_class.module_pages.pluck(:id)).pluck(:id)
    end
  end

end
