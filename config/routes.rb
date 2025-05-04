Rails.application.routes.draw do
  # ホスト関連のルート
  devise_for :hosts
  resources :hosts, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
  member do
      get 'events/new', to: 'hosts#new_event', as: :new_event
      post 'events', to: 'hosts#create_event', as: :events
  
      get 'facility', to: 'facilities#show', as: :facility
    end
      resources :events, only: [:edit, :update, :destroy], controller: 'hosts'
  end

  # セラー関連のルート
  devise_for :sellers
  resources :sellers, only: [:index, :show, :new, :create, :edit, :update, :destroy]

  # 管理者関連のルート
  devise_for :administrators, path: "administrators", controllers: {
    sessions: "admin/sessions",
    registrations: "admin/registrations"
  }

  namespace :admin do
    resources :sellers, controller: 'admin_sellers', only: [:index, :edit, :update] do
      resources :comments, only: [:create], module: :sellers
    end
    resources :hosts, controller: 'admin_hosts', only: [:index, :edit, :update] do
      resources :comments, only: [:create], module: :hosts
    end
    resources :events, only: [:index, :edit, :update, :destroy]
    resources :users do
      resources :comments, only: [:create], module: :users
    end
    root to: "users#index"
  end

  # ユーザー関連のルート
  devise_for :users

  # 施設関連のルート
  resources :facilities, only: [:index, :show]
  resource :facility, only: [:show, :new, :create, :edit, :update, :destroy], controller: 'facility'
 

  # イベント関連のルート
  resources :events

  # アプリケーションのルート
  root "home#index"
end
