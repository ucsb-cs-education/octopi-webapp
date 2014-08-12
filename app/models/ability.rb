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
      can :access, :ckeditor
      files = LaplayaFile.with_role(:owner, user).pluck(:id)
      can :crud, LaplayaFile, id: files
      can :crud, LaplayaFile, user_id: user.id
      can :create, LaplayaFile

      if user.class == Staff
        #All users can edit themselves
        can :crud, Staff, :id => user.id
        can :read, ActiveAdmin::Page, :name => 'Dashboard'
        can [:read, :create, :destroy], Ckeditor::Picture
        can [:read, :create, :destroy], Ckeditor::AttachmentFile


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
    can :add_basic_roles, Staff
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
    can :add_basic_roles, Staff
    schools = School.with_role(:school_admin, user)
    school_ids = schools.pluck(:id)
    cannot :read, School, :id => School.pluck(:id) - schools
    can [:read_update, :add_teacher, :add_school_admin], School, id: school_ids

    can [:crud, :change_class, :remove_class], Student, :id => Student.where(school_id: school_ids).pluck(:id)
    can :create, Student

    school_classes = SchoolClass.where(school_id: school_ids)
    school_classes_ids = school_classes.pluck(:id)
    can [:crud, :add_class_teacher, :add_new_student, :add_student], SchoolClass, id: school_classes_ids
    can :create, SchoolClass

    staff_school_roles = Role.where(name: [:teacher, :school_admin], resource_type: 'School', resource_id: school_ids)
    staff_school_class_roles = Role.where(name: [:teacher], resource_type: 'SchoolClass', resource_id: school_classes_ids)
    roles = []
    [staff_school_roles, staff_school_class_roles].each do |staff_roles|
      roles.push *(staff_roles.map { |x| {name: x.name, resource: x.resource} })
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
    can :read, LaplayaFile, {:curriculum_id => page_ids, :type => 'TaskBaseLaplayaFile'}
    can :see_user_admin_menu

    can :manual_unlock, SchoolClass, :id => school_classes_ids
    can :activity_page, SchoolClass, :id => school_classes_ids
  end

  def teacher(user)
    can :add_basic_roles, Staff
    #this is really awful. We need to clean this up, a lot...

    schools = School.with_role(:teacher, user).pluck(:id)
    can :read, School, :id => schools
    can :read, Student, :id => Student.where(school_id: schools).pluck(:id)

    school_classes = SchoolClass.with_role(:teacher, user).pluck(:id)
    school_classes_teacher = SchoolClass.with_role(:teacher, user).pluck(:school_id)
    schools_teacher = School.with_role(:teacher, user).pluck(:id)
    if School.with_role(:teacher, user) != []
      cannot :read, School, :id => School.pluck(:id) - schools_teacher
      can :read, School, :id => schools_teacher
      can [:crud, :change_class, :remove_class], Student, :id => Student.where(school_id: schools_teacher).pluck(:id)
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
    can :read_update, SchoolClass, :id => school_classes
    can :crud, Student, :id => Student.joins(:school_classes).where(school_classes: {id: school_classes}).distinct.pluck(:id)
    can :read, Page, {curriculum_id: page_ids, visible_to_teachers: true}
    can :read, Task, {curriculum_id: page_ids, visible_to_teachers: true}
    assessment_task_ids = AssessmentTask.teacher_visible.where(curriculum_id: page_ids).pluck(:id)
    laplaya_task_ids = LaplayaTask.teacher_visible.where(curriculum_id: page_ids).pluck(:id)
    can :read, AssessmentQuestion, assessment_task_id: assessment_task_ids
    can :show, LaplayaFile, {parent_id: laplaya_task_ids, type: %w(TaskBaseLaplayaFile TaskCompletedLaplayaFile)}
    can :manual_unlock, SchoolClass, id: school_classes

    can :create, Student
  end

  def student(user)
    can :read, Student, id: user
    if (user.respond_to? :current_class) && (user.current_class.present?)
      module_page_ids = user.current_class.module_pages
      can :show, LaplayaFile, id: SandboxBaseLaplayaFile.where(parent_id: module_page_ids).pluck(:id)
      demo_laplaya_tasks = LaplayaTask.where(demo: true, page_id: ActivityPage.where(page_id: module_page_ids).pluck(:id))
      can :show, LaplayaFile, id: TaskCompletedLaplayaFile.where(laplaya_task: demo_laplaya_tasks).pluck(:id)
    end
  end

end
