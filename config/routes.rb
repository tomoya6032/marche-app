Rails.application.routes.draw do
  get "faqs/index"
# ホスト関連のルート
devise_for :hosts
resources :hosts, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
  resources :events, only: [:index, :show, :new, :create, :edit, :update, :destroy], module: :hosts
end

resources :hosts do
  resources :events, only: [:index, :show, :new, :create, :edit, :update, :destroy], module: :hosts
end

  # セラー関連のルート
  devise_for :sellers, controllers: {
    # sessions: 'sellers/sessions',
    # registrations: 'sellers/registrations'
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
   
  
  # 一般ユーザー向けFAQページ
  # /faq でアクセスできるようにし、`FaqsController`の`index`アクションで処理します。
  # `as: :public_faqs` で `public_faqs_path` ヘルパーが使えるようになります。
  get 'faq', to: 'faqs#index', as: :public_faqs
  
  namespace :admin do

    # FAQ管理用のリソースルーティングをここに追加します。
    # `except: [:show]` を使うことで、個別のFAQ詳細ページは作成せず、
    # 外部noteへのリンクに飛ばすという要件に合わせられます。
    resources :faqs, except: [:show]
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
    get 'admin', to: 'admin/users#index'
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

  # config/routes.rb
  get '/.well-known/appspecific/com.chrome.devtools.json', to: proc { [404, {}, ['Not Found']] }
  get 'administrator', to: 'admin/users#index', as: :administrator_dashboard
end
