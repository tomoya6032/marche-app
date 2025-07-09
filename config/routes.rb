# config/routes.rb

Rails.application.routes.draw do

  # ==============================
  # FAQ関連のルート
  # ==============================
  get "faqs/index"
  get 'faq', to: 'faqs#index', as: :public_faqs

  # ==============================
  # 認証関連のルート (Devise)
  # ==============================
  devise_for :hosts, path: 'auth' # Devise for hosts (generates paths like /auth/sign_in)
  devise_for :sellers
  devise_for :administrator, path: "administrator", controllers: {
    sessions: "admin/sessions",
    registrations: "admin/registrations"
  }
  devise_for :users

  # ==============================
  # グローバルなイベント一覧・詳細
  # ==============================
  resources :events

  # ==============================
  # ホスト関連のカスタムルート (スラッグベースより先に定義)
  # ★★★ resources :hosts を削除したため、必要なアクションを明示的に定義します ★★★
  # ==============================

  # ホストの一覧ページ (もし必要なら)
  get 'hosts', to: 'hosts#index', as: :hosts # hosts_path を明示的に定義

  # ホストの新規作成ページ
  get 'hosts/new', to: 'hosts#new', as: :new_host

  # ホストの作成アクション
  post 'hosts', to: 'hosts#create', as: :create_host # ヘルパー名を hosts にしても衝突する可能性があるため

  # ホストプロフィール編集・更新ルート (host_id を使う)
  get ':host_id/edit_profile', to: 'hosts#edit', as: :edit_host_profile, constraints: { host_id: /[a-zA-Z0-9_-]+/ }
  patch ':host_id', to: 'hosts#update', as: :update_host_profile, constraints: { host_id: /[a-zA-Z0-9_-]+/ }
  put ':host_id', to: 'hosts#update', constraints: { host_id: /[a-zA-Z0-9_-]+/ } # PATCHとPUT両方に対応するため

  # ホストの削除アクション
  delete ':host_id', to: 'hosts#destroy', as: :destroy_host_profile, constraints: { host_id: /[a-zA-Z0-9_-]+/ }


  # ==============================
  # ホストのネストされたイベント関連ルート (as: :host_profile は削除済み)
  # ==============================
  scope ':host_id', constraints: { host_id: /[a-zA-Z0-9_-]+/ } do
    get 'events/new', to: 'hosts#new_event', as: :new_host_event
    post 'events', to: 'hosts#create_event', as: :host_events

    get 'events/:id/edit', to: 'hosts#edit_event', as: :edit_host_event
    patch 'events/:id', to: 'hosts#update_event', as: :update_host_event
    delete 'events/:id', to: 'hosts#destroy_event', as: :destroy_host_event
    get 'events/:id', to: 'hosts#show_event', as: :host_event
  end

  # ==============================
  # セラー関連のルート
  # ==============================
  resources :sellers, only: [:index, :show, :edit, :update] do # index を追加 (必要に応じて)
    resources :events, only: [:new, :create]
  end

  # ==============================
  # 施設関連のルート
  # ==============================
  resources :facilities, only: [:index, :show]
  resource :facility, only: [:show, :new, :create, :edit, :update, :destroy], controller: 'facility'

  # ==============================
  # 管理者関連のルート
  # ==============================
  get 'administrator', to: 'admin/users#index', as: :administrator_dashboard
  namespace :admin do
    resources :faqs, except: [:show]
    resources :users
    resources :notices

    resources :sellers, controller: 'admin_sellers', only: [:index, :show, :edit, :update] do
      patch :toggle_editable, on: :member
      resources :comments, only: [:create], module: :sellers
    end

    resources :hosts, controller: 'admin_hosts', only: [:index, :show, :edit, :update, :destroy] do # destroy も追加
      resources :comments, only: [:create], module: :hosts
      patch :toggle_editable, on: :member
    end

    resources :events, only: [:index, :edit, :update, :destroy] do
      collection do
        post :featured
      end
    end

    resources :users, only: [:index, :show, :edit, :update] do
      resources :comments, only: [:create], module: :users
    end

    root to: "users#index"
  end

  # ==============================
  # その他アプリケーション固有のルート
  # ==============================
  get 'recruitment', to: 'home#recruitment', as: 'recruitment'

  # ==============================
  # ★★★ 最重要: ホストのスラッグベースのプロフィールルート ★★★
  # これが `/mimamoru-lab` のようなURLを処理します。
  # 他の固定パス（例: /about, /contact）との衝突を避けるため、
  # これらの固定パスより「後」に配置してください。
  # ==============================
  get ':id_or_slug', to: 'hosts#show', as: :public_host_profile, constraints: { id_or_slug: /[a-zA-Z0-9\-_]+/ }


  # アプリケーションのルート
  root "home#index"

  # DevTools 関連のパス
  get '/.well-known/appspecific/com.chrome.devtools.json', to: proc { [404, {}, ['Not Found']] }

end