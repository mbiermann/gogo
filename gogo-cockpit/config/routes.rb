Rails.application.routes.draw do

  resources :invites
  resources :invites do
    member do
      post 'grant'
    end
  end

  resources :apps do
    resources :owners, controller: 'ownerships'
    resources :placements
  end

  resources :ownerships
  resources :placements do
    resources :campaigns do 
      resources :assets
    end
  end
  resources :campaigns, :only => [:index, :show, :edit, :update, :destroy]
  post "campaigns/:id/toggle" => "campaigns#toggle", :as => :toggle_campaign
  resources :assets, :only => [:show, :edit, :update, :destroy]
  
  get 'placements/:placement_id/assets/modulo/:int' => 'placements#modulo'
  
  devise_for :users, :controllers => { 
    :registrations => "registrations", 
    :omniauth_callbacks => "omniauth_callbacks#google_oauth2",
  }
  devise_scope :users do
    post "users/:id/toggle" => "users#toggle", :as => :toggle_user
    get "users/index" => "users#index"
    delete "users/:id" => "users#destroy"
  end
  resources :users

  get 'assets/:id/raw' => 'assets#raw', :as => :raw_asset

  root 'home#index'

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
