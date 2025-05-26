Rails.application.routes.draw do
# ホスト関連のルート
devise_for :hosts
resources :hosts, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
  resources :events, only: [:index, :show, :new, :create, :edit, :update, :destroy], module: :hosts
end

  # セラー関連のルート
  devise_for :sellers, controllers: {
    sessions: 'sellers/sessions'
  }
    
  resources :sellers, only: [:index, :show, :new, :create, :edit, :update, :destroy]
 
 # 管理者関連のルート
  devise_for :administrator, path: "administrator", controllers: {
    sessions: "admin/sessions",
    registrations: "admin/registrations"
    
  }

  # `/administrator`をダッシュボードに設定
    get 'administrator', to: 'admin/users#index'
    

  # devise_for :administrators, path: "administrators", controllers: {
  #   sessions: "admin/sessions",
  #   registrations: "admin/registrations"
  # }

  namespace :admin do
    
    resources :users
    resources :notices
    resources :sellers, controller: 'admin_sellers', only: [:index, :show, :edit, :update] do
      patch :toggle_editable, on: :member
      resources :comments, only: [:create], module: :sellers
    end
    resources :hosts, controller: 'admin_hosts', only: [:index, :show, :edit, :update] do
      resources :comments, only: [:create], module: :hosts
      patch :toggle_editable, on: :member
    end
    resources :events, only: [:index, :edit, :update, :destroy] do
      collection do
        post :featured # 注目イベントを更新するルート
      end
    end
    resources :users, only: [:index, :show, :edit, :update] do
      
      resources :comments, only: [:create], module: :users
    end
    root to: "users#index"
  end

  # 出展者募集のページ
  get 'recruitment', to: 'home#recruitment', as: 'recruitment'
  
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
