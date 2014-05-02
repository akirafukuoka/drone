Drone::Application.routes.draw do

  get "oauths/autoposts" => "oauths#autoposts"
  resources :oauths
  # resources :entries
  get "oauths/:oauth_id/entries" => "entries#index"
  get "oauths/:oauth_id/entries/timer" => "entries#timer"
  get "oauths/:oauth_id/entries/schedule" => "entries#schedule"
  get "oauths/:oauth_id/entries/closed" => "entries#closed"
  get "oauths/:oauth_id/entries/tags" => "entries#tags"
  get "oauths/:oauth_id/entries/tags/:tag" => "entries#tag"
  get "oauths/:oauth_id/entries/search" => "entries#search"
  post "oauths/:oauth_id/entries" => "entries#create"
  get "oauths/:oauth_id/entries/new" => "entries#new"
  get "oauths/:oauth_id/entries/:id" => "entries#show"
  get "oauths/:oauth_id/entries/:id/edit" => "entries#edit"
  patch "oauths/:oauth_id/entries/:id" => "entries#update"
  put "oauths/:oauth_id/entries/:id" => "entries#update"
  delete "oauths/:oauth_id/entries/:id" => "entries#destroy"
  get "oauths/:oauth_id/entries/:id/share" => "entries#share"





  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'oauths#index'

  get "sessions/create" => "sessions#create"
  match "/auth/:provider/callback" => "sessions#create", via: [:get, :post]
  match "/signout" => "sessions#destroy", via: [:get, :post]

  match "/login" => "statics#login", via: [:get, :post]
  match "/login_session" => "statics#login_session", via: [:get, :post]
  match "/logout" => "statics#logout", via: [:get, :post]

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
