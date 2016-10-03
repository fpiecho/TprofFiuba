Rails.application.routes.draw do
  
  resources :mobile_app_screens
  resources :mobile_apps
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations', 
                                    passwords: 'users/passwords',
                                    :omniauth_callbacks => "users/omniauth_callbacks" }


  get 'welcome/index'
  match '/mobile_apps/build/:id', to: 'mobile_apps#build', as: 'build', :via => [:get,:post], :as => :mobile_apps_build
  match '/mobile_apps/pages/:id/:name', to: 'mobile_apps#new_page', as: 'new_tab', :via => [:get,:post], :as => :mobile_apps_new_page
  match '/mobile_apps/pages/:id/:name', to: 'mobile_apps#delete_page', as: 'delete_page', :via => [:delete], :as => :mobile_apps_delete_page
  match '/mobile_apps/content/:id/:name', to: 'mobile_apps#set_content', as: 'set_content', :via => [:get,:post], :as => :mobile_apps_set_content

  match '/mobile_apps/menu/:id', to: 'mobile_apps#menu', as: 'menu', :via => [:get,:post], :as => :mobile_apps_menu

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

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
