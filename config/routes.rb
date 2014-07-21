require "resque_web"

OctopiWebapp::Application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'
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

    scope module: 'laplaya' do
      match '/laplaya', to: 'laplaya_base#laplaya', via: 'get'
      match '/laplaya/:id', to: 'laplaya_base#laplaya_file', via: 'get', as: 'laplaya_file'
    end

    scope 'modules' do
      get ':id', to: 'pages#module_page', as: 'module'
      get ':id/laplaya_sandbox', to: 'pages#laplaya_sandbox', as: 'module_sandbox'
      scope module: 'laplaya' do
        get ':module_page_id/laplaya_files', to: 'laplaya_sandbox#index', as: 'module_sandbox_files'
        post ':module_page_id/laplaya_files', to: 'laplaya_sandbox#create'
      end
    end

    get '/activities/:id', to: 'pages#activity_page', as: 'activity'

    get '/assessment_tasks/:id', to: 'pages#assessment_task', as: 'assessment_task'
    post '/assessment_tasks/:id', to: 'pages#assessment_response', as: 'assessment_task_response'

    get '/laplaya_tasks/:id', to: 'pages#laplaya_task', as: 'laplaya_task'
    post '/laplaya_tasks/:id', to: 'pages#laplaya_task_response', as: 'laplaya_task_response'

    get '/offline_tasks/:id', to: 'pages#offline_task', as: 'offline_task'
  end
  match '/school_classes/:school_class_id/student_logins.json', to: 'student_portal/sessions#list_student_logins', format: false, via: 'get'
  match '/schools/:school_id/school_classes.json', to: 'student_portal/sessions#list_school_classes', format: false, via: 'get'


  resources :laplaya_files, only: [:show, :update, :destroy, :create, :index], format: false, controller: 'student_portal/laplaya/laplaya_files' do
  end






  resources :schools, only: [:show, :index], shallow: true do
    resources :students, except: [:update, :edit, :destroy]
    resources :school_classes do
      member do
        post 'add_new_student'
        post 'add_student'
      end
    end
  end
  root 'static_pages#home'
  get 'home', to: 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/sign_in', to: redirect('/student_portal/signin')
  get '/signin', to: redirect('/student_portal/signin')
  get '/admin/staff/roles/:role_name', to: 'roles#get_resources', format: true
  get '/admin/staff/roles/:role_name/:resource_name/:resource_id', to: 'roles#get_roles', format: true
  namespace :staff do
    root 'static_pages#home'
    get 'home', to: 'static_pages#home'
  end
  devise_for :staff, controllers: {sessions: 'staff/sessions', confirmations: 'staff/confirmations'}, skip: [:registrations]
  as :staff do
    get 'staff/sign_up', to: 'staff/registrations#new', as: 'new_staff_registration'
    post 'staff', to: 'staff/registrations#create', as: 'staff_registration'
  end
  ActiveAdmin.routes(self)



  scope module: 'pages' do
    resources :curriculum_pages, path: 'curriculums', except: [:create, :edit], shallow: true do
      member do
      end
      resources :module_pages, path: 'modules', except: [:index, :edit], shallow: true do
        member do
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
              patch :clone
              patch :clone_completed
              patch :analysis_file, to: :update_laplaya_analysis_file
              get :analysis_file, to: :get_laplaya_analysis_file
            end
            resources :task_dependencies, only: [:destroy, :create]
            resources :activity_dependencies, only: [:destroy, :create]
          end

          resources :assessment_tasks, except: [:index, :edit], shallow: true do
            resources :task_dependencies, only: [:destroy, :create]
            resources :activity_dependencies, only: [:destroy, :create]
            resources :assessment_questions, except: [:index, :edit], shallow: true
          end
        end
      end
    end
  end

  resque_web_constraint = lambda do |request|
    current_staff = request.env['warden'].user
    current_staff.present? && current_staff.respond_to?(:has_role?) && current_staff.has_role?(:super_staff)
  end

  ResqueWeb::Engine.eager_load!
  constraints resque_web_constraint do
    mount ResqueWeb::Engine => '/resque_web'
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
