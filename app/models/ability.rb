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

    can :show, LaplayaFile, public: true

    alias_action :create, :read, :update, :destroy, :to => :crud
    alias_action :create, :show, :update, :destroy, :to => :csud #crud without index
    alias_action :read, :update, :destroy, :to => :rud
    alias_action :read, :update, :to => :read_update
    if user
      can :create_public_laplaya_files, LaplayaFile
      can :access, :ckeditor
      files = LaplayaFile.with_role(:owner, user).pluck(:id)
      can :rud, LaplayaFile, id: files
      can :rud, LaplayaFile, user_id: user.id

      if user.is_a? Staff
        can :create, LaplayaFile
        #All users can edit themselves
        can :crud, Staff, :id => user.id
        can :read, ActiveAdmin::Page, :name => 'Dashboard'
        can [:create], Ckeditor::Picture
        can [:create], Ckeditor::AttachmentFile
        can [:read, :destroy], Ckeditor::Picture, assetable: user
        can [:read, :destroy], Ckeditor::AttachmentFile, assetable: user

        cannot :update, Staff.with_role(:super_staff).where.not(id: user)
        cannot :destroy, Staff.with_role(:super_staff).where.not(id: user)
        if user.has_role? :super_staff
          super_staff(user)
        else
          school_admin(user) if user.has_role? :school_admin, :any
          teacher(user) if user.has_role? :teacher, :any
          curriculum_designer(user) if user.has_role? :curriculum_designer, :any
        end
      elsif user.is_a? Student
        student(user)

      end
    end
  end

  def curriculum_designer(user)
    can :add_basic_roles, Staff
    page_ids = CurriculumPage.with_role(:curriculum_designer, user).pluck(:id)
    can [:crud, :add_designer, :show_sandbox_file, :show_project_file, :save_version], Page, :curriculum_id => page_ids
    can [:crud, :clone, :clone_completed,
         :update_laplaya_analysis_file, :get_laplaya_analysis_file,
         :show_completed_file, :show_base_file, :save_version, :delete_all_responses], Task, :curriculum_id => page_ids
    can :crud, AssessmentQuestion, :curriculum_id => page_ids
    can [:show, :update], LaplayaFile, {:curriculum_id => page_ids, :type => %w(TaskBaseLaplayaFile SandboxBaseLaplayaFile ProjectBaseLaplayaFile TaskCompletedLaplayaFile)}

    can [:read, :destroy], Ckeditor::Picture, {resource_type: 'Page', resource_id: page_ids}
    can [:read, :destroy], Ckeditor::AttachmentFile, {resource_type: 'Page', resource_id: page_ids}

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
    can :see_user_admin_menu

    schools = School.with_role(:school_admin, user).pluck(:id)
    can [:read_update, :add_teacher, :add_school_admin], School, id: schools
    can :read, Student, :id => Student.where(school_id: schools).pluck(:id)
    school_classes = SchoolClass.where(school_id: schools).pluck(:id)
    school_admin_teacher_shared(user, school_classes, schools)

    staff_school_roles = Role.where(name: [:teacher, :school_admin], resource_type: 'School', resource_id: schools)
    staff_school_class_roles = Role.where(name: [:teacher], resource_type: 'SchoolClass', resource_id: school_classes)
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
  end

  def teacher(user)
    can :add_basic_roles, Staff
    schools = School.with_role(:teacher, user).pluck(:id)
    can :read, School, :id => schools
    can :read, Student, :id => Student.where(school_id: schools).pluck(:id)
    school_classes = SchoolClass.with_role(:teacher, user).pluck(:id)
    school_admin_teacher_shared(user, school_classes, schools)

  end

  def school_admin_teacher_shared(user, school_classes_ids, school_ids)
    # school = user.school
    # page_ids = school.curriculum_pages.pluck(:id)
    # I Really don't like this. I'd like to do what is above, but I have no idea how to do it efficiently
    # Really, we just need to remove the concept of multiple curriculums entirely. It would make everything SO much easier to permission
    page_ids = CurriculumPage.all
    can :read, Page, id: page_ids
    can :read, Page, {curriculum_id: page_ids, teacher_visible: true}
    can [:read, :show_completed_file, :show_base_file], Task, {curriculum_id: page_ids, teacher_visible: true}
    can :read, AssessmentQuestion, {curriculum_id: page_ids}
    laplaya_task_ids = LaplayaTask.teacher_visible.where(curriculum_id: page_ids).pluck(:id)
    can :read, LaplayaFile, {parent_id: laplaya_task_ids, type: 'TaskBaseLaplayaFile TaskCompletedLaplayaFile SandboxBaseLaplayaFile ProjectBaseLaplayaFile'}

    can [
            :read_update,
            :manual_unlock,
            :edit_students_via_csv,
            :do_csv_actions,
            :download_class_csv,
            :student_spreadsheet_help,
            :add_new_student,
            :add_student,
            :edit_students,
            :view_as_student,
            :signout_test_student,
            :reset_test_student,
            :activity_page
        ], SchoolClass, :id => school_classes_ids
    can [:crud, :change_class, :remove_class], Student, school_id: school_ids
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
