OctopiWebapp::Application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'
  namespace :student_portal do
    resources :sessions, only: [:create] #, :destroy]
    root 'static_pages#home'
    match '/help', to: 'static_pages#help', via: 'get'
    match '/about', to: 'static_pages#about', via: 'get'
    match '/contact', to: 'static_pages#contact', via: 'get'
    match '/laplaya', to: 'static_pages#laplaya', via: 'get'
    match '/home', to: redirect('/'), via: 'get'
    match '/signin', to: 'sessions#new', via: 'get'
    match '/signout', to: 'sessions#destroy', via: 'delete'
  end

  resources :laplaya_files, only: [:show, :update, :destroy, :create, :index], format: false, controller: 'student_portal/laplaya/laplaya_files' do
  end

  #resources :assessment_questions, only: [:show, :update, :destroy, :create, :index], format: false, controller:

  resources :schools, only: [:show, :index], shallow: true do
    match '/student_logins.json', to: 'students#list_student_logins', format: false, via: 'get'
    resources :students, except: [:update, :edit, :destroy]
    resources :school_classes do
      member do
        post 'add_new_student'
        post 'add_student'
      end
      # match '/add_student', to: 'school_classes#add_student', via: 'post', as: 'add_student'
      # match '/add_new_student', to: 'school_classes#add_new_student', via: 'post', as: 'add_new_student'
    end
  end
  root 'static_pages#home'
  get 'home', to: 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/sign_in', to: redirect('/student_portal/signin')
  get '/signin', to: redirect('/student_portal/signin')
  namespace :staff do
    root 'static_pages#home'
    get 'home', to: 'static_pages#home'
  end
  devise_for :staff, controllers: { sessions: 'staff/sessions', confirmations: 'staff/confirmations' } , skip: [:registrations]
  as :staff do
    get 'staff/sign_up', to: 'staff/registrations#new', as: 'new_staff_registration'
    post 'staff', to: 'staff/registrations#create', as: 'staff_registration'
  end
  ActiveAdmin.routes(self)

  scope module: 'pages' do
    resources :curriculum_pages, path: 'curriculums', except: [:create, :edit], shallow: true do
      member { post :sort }
      resources :module_pages, path: 'modules', except: [:index, :edit], shallow: true do
        member { post :sort }
        resources :activity_pages, path: 'activities', except: [:index, :edit], shallow: true do
          member { post :sort }
          resources :laplaya_tasks, except: [:index, :edit], shallow: true do
            member do
              patch 'clone'
            end
          end
          resources :assessment_tasks, except: [:index, :edit], shallow: true do
            member {post :sort}
            resources :assessment_questions, except: [:index, :edit], shallow: true do
            end
          end
        end
      end
    end
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
