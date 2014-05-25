OctopiWebapp::Application.routes.draw do

  namespace :student_portal do
    resources :sessions, only: [:create ]#, :destroy]
    root 'static_pages#home'
    match '/help',    to: 'static_pages#help',    via: 'get'
    match '/about',   to: 'static_pages#about',   via: 'get'
    match '/contact', to: 'static_pages#contact', via: 'get'
    match '/laplaya',    to: 'static_pages#laplaya',    via: 'get'
    match '/home',    to: redirect('/'),          via: 'get'
    match '/signin',  to: 'sessions#new',         via: 'get'
    match '/signout', to: 'sessions#destroy',     via: 'delete'
    namespace :laplaya do
      scope '/saves/' do
        resources :laplaya_files, only: [:show, :update, :destroy, :create, :index], format: false do
        end
      end

    end
  end

  resources :schools do
    match '/student_logins.json', to: 'students#list_student_logins', via: 'get'
    resources :students do
    end
    resources :school_classes do
      match '/add_student', to: 'school_classes#add_student', via: 'post', as: 'add_student'
    end
  end


  root  'static_pages#home'
  match '/home',    to: 'static_pages#home',                    via: 'get'
  match '/help',    to: 'static_pages#help',                    via: 'get'
  match '/sign_in', to: redirect('/student_portal/signin'),     via: 'get'
  match '/signin',  to: redirect('/student_portal/signin'),     via: 'get'
  devise_for :staff
  ActiveAdmin.routes(self)

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
