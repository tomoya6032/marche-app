Rails.application.routes.draw do
  devise_for :hosts
  
  
  get "facility/index"
  resources :facilities do
    resources :events, only: [:index] # facilitiesに紐づくeventsのindexアクションのみルーティング
  end

  get "facility/show"

  resources :events, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  


  resources :sellers, only: [:index, :show, :new, :create, :edit, :update, :destroy]
 
 
  
  devise_for :sellers



  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  # get '/' => 'home#index'
  root 'home#index'

  

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
