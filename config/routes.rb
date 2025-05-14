Rails.application.routes.draw do
# ホスト関連のルート
devise_for :hosts
resources :hosts, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
  resources :events, only: [:index, :show, :new, :create, :edit, :update, :destroy], module: :hosts
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
    resources :sellers, controller: 'admin_sellers', only: [:index, :show, :edit, :update] do
      resources :comments, only: [:create], module: :sellers
    end
    resources :hosts, controller: 'admin_hosts', only: [:index, :show, :edit, :update] do
      resources :comments, only: [:create], module: :hosts
    end
    resources :events, only: [:index, :edit, :update, :destroy]
    resources :users, only: [:index, :show, :edit, :update] do # :show を追加
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

  # resources :hosts do
  #   resources :events, only: [:new, :create, :edit, :update, :destroy], module: :hosts
  # end

  # アプリケーションのルート
  root "home#index"
end
