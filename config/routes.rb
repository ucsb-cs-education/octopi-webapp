require 'resque_web'

OctopiWebapp::Application.routes.draw do

  namespace :student_portal do
    resources :sessions, only: [:create] #, :destroy]
    root 'static_pages#home', as: ''
    root 'static_pages#home'
    match '/help', to: 'static_pages#help', via: 'get'
    match '/about', to: 'static_pages#about', via: 'get'
    match '/contact', to: 'static_pages#contact', via: 'get'
    match '/home', to: redirect('/'), via: 'get'
    match '/signin', to: 'sessions#new', via: 'get'
    match '/signout', to: 'sessions#destroy', via: 'delete'
    get '/profile', to: 'students#show', as: 'profile'
    patch '/profile', to: 'students#update'

    scope module: 'laplaya' do
      match '/laplaya', to: 'laplaya_base#laplaya', via: 'get'
      match '/laplaya/:id', to: 'laplaya_base#laplaya_file', via: 'get', as: 'laplaya_file'
    end

    scope 'modules' do
      get ':id', to: 'pages#module_page', as: 'module'
      get ':id/laplaya_sandbox', to: 'pages#laplaya_sandbox', as: 'module_sandbox'
      get ':id/design_thinking_project', to: 'pages#design_thinking_project', as: 'module_project'
      get ':id/laplaya_sandbox/:file_id', to: 'pages#laplaya_sandbox_file', as: 'module_sandbox_laplaya_file'
      scope module: 'laplaya' do
        get ':module_page_id/laplaya_files', to: '/laplaya_sandbox#index', as: 'module_sandbox_files'
        post ':module_page_id/laplaya_files', to: '/laplaya_sandbox#create'
      end
    end

    get '/activities/:id', to: 'pages#activity_page', as: 'activity'

    get '/question_tasks/:id', to: 'pages#assessment_task', as: 'assessment_task'
    post '/question_tasks/:id', to: 'pages#assessment_response', as: 'assessment_task_response'

    get '/laplaya_tasks/:id', to: 'pages#laplaya_task', as: 'laplaya_task'
    post '/laplaya_tasks/:id', to: 'pages#laplaya_task_response', as: 'laplaya_task_response'

    get '/offline_tasks/:id', to: 'pages#offline_task', as: 'offline_task'
  end
  match '/school_classes/:school_class_id/student_logins.json', to: 'student_portal/sessions#list_student_logins', format: false, via: 'get'
  match '/schools/:school_id/school_classes.json', to: 'student_portal/sessions#list_school_classes', format: false, via: 'get'


  resources :laplaya_files, only: [:show, :update, :destroy, :create, :index], format: false, defaults: {format: :json} do
  end

  get '/laplaya_files/:id.xml', format: false, defaults: {format: :xml}, to: 'laplaya_files#show'

  #match '/school_classes/:school_class_id/activities/:id', to: 'school_classes#activity_page', via: 'get', as: 'activity'

  get '/school_classes/', to: 'school_classes#teacher_index', as: 'teacher_school_classes'
  resources :schools, only: [:show, :index], shallow: true do
    resources :students, except: [:update, :edit, :destroy]
    resources :school_classes do
      member do
        post 'add_new_student'
        post 'add_student'
        post 'manual_unlock', format: false
      end
      resources :unlocks, only: [:destroy, :create]
      get '/activities/:id', to: 'school_classes/school_classes_activities#activity_page', as: 'activity'
      get '/student/:id', to: 'school_classes/school_classes_student_progress#student_progress', as: 'student_progress'
      get '/reset_dependency_graph', to: 'school_classes/school_classes_student_progress#reset_dependency_graph'
      get '/view_as_student', to: 'school_classes#view_as_student', as: 'view_as_student'
      match '/signout_test_student', to: 'school_classes#signout_test_student', as: 'signout_test_student', via: 'delete'
      match '/reset_test_student', to: 'school_classes#reset_test_student', as: 'reset_test_student', via: 'delete'
    end


  end
  root 'static_pages#home'
  get 'home', to: 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/contact', to: 'static_pages#contact'
  post '/contact', to: 'static_pages#send_contact'
  get '/sign_in', to: redirect('/student_portal/signin')
  get '/signin', to: redirect('/student_portal/signin')
  get '/admin/staff/roles/:role_name', to: 'roles#get_resources', format: true
  get '/admin/staff/roles/:role_name/:resource_name/:resource_id', to: 'roles#get_roles', format: true

  namespace :staff do
    root 'static_pages#home'
    get 'home', to: 'static_pages#home'
    get 'laplaya', to: 'static_pages#laplaya'
    get 'laplaya/:id', to: 'static_pages#laplaya_file', as: 'laplaya_file'
  end
  devise_for :staff, controllers: {sessions: 'staff/sessions', confirmations: 'staff/confirmations'}, skip: [:registrations]
  as :staff do
    get 'staff/sign_up', to: 'staff/registrations#new', as: 'new_staff_registration'
    post 'staff', to: 'staff/registrations#create', as: 'staff_registration'
  end
  ActiveAdmin.routes(self)
  get '/curriculums*curriculapath', to: redirect { |params, req| "/curricula#{params[:curriculapath]}" }
  get '/curriculums', to: redirect('/curricula')
  scope module: 'pages' do
    resources :curriculum_pages, path: 'curricula', except: [:create, :edit], shallow: true do
      member do
      end
      resources :module_pages, path: 'modules', except: [:index, :edit], shallow: true do
        member do
          get :project_file, to: :show_project_file
          get :sandbox_base_file, to: :show_sandbox_file
          patch :clone_sandbox
          patch :clone_project
        end
        resources :activity_pages, path: 'activities', except: [:index, :edit], shallow: true do
          member do
          end
          resources :activity_dependencies, only: [:destroy, :create]
          resources :offline_tasks, except: [:index, :edit], shallow: true do
            resources :task_dependencies, only: [:destroy, :create]
            resources :activity_dependencies, only: [:destroy, :create]
          end
          resources :laplaya_tasks, except: [:index, :edit], shallow: true do
            member do
              get :base_file, to: :show_base_file
              get :solution_file, to: :show_completed_file
              patch :clone
              patch :clone_completed
              patch :analysis_file, to: :update_laplaya_analysis_file
              delete :delete_all_responses
              get :analysis_file, to: :get_laplaya_analysis_file
            end
            resources :task_dependencies, only: [:destroy, :create]
            resources :activity_dependencies, only: [:destroy, :create]
          end

          resources :assessment_tasks, except: [:index, :edit], shallow: true do
            member do
              delete :delete_all_responses
            end
            resources :task_dependencies, only: [:destroy, :create]
            resources :activity_dependencies, only: [:destroy, :create]
            resources :assessment_questions, except: [:index, :edit], shallow: true
          end
        end
      end
    end
  end

  mount Ckeditor::Engine => '/ckeditor'

  resque_web_constraint = lambda do |request|
    current_staff = request.env['warden'].user
    current_staff.present? && current_staff.respond_to?(:has_role?) && current_staff.has_role?(:super_staff)
  end

  ResqueWeb::Engine.eager_load!
  constraints resque_web_constraint do
    mount ResqueWeb::Engine => '/resque_web'
  end

end
