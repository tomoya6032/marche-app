# config/routes.rb

Rails.application.routes.draw do
  # ==============================
  # FAQ関連のルート
  # ==============================
  get "faq", to: "faqs#index", as: :public_faqs

  # ==============================
  # 認証関連のルート (Devise)
  # ==============================
  devise_for :hosts, path: "auth" # Devise for hosts (generates paths like /auth/sign_in)
  devise_for :sellers
  devise_for :administrator, path: "administrator", controllers: {
    sessions: "admin/sessions",
    registrations: "admin/registrations"
  }
  devise_for :users

  # --- ★★★ ここからが修正箇所です！ ★★★ ---

  # ==============================
  # 管理者関連のルート（他の汎用ルートより優先）
  # ==============================
  # 管理者ダッシュボードへの直接アクセスルート
  get "administrator", to: "admin/users#index", as: :administrator_dashboard

  namespace :admin do
    # デフォルトのルート（/admin にアクセスした時の動作）
    root to: "users#index" # /admin にアクセスすると admin/users#index へ

    # FAQ管理ルート
    resources :faqs, except: [ :show ]

    # Users管理ルート（コメント機能を含む）
    resources :users, only: [ :index, :show, :edit, :update ] do
      resources :comments, only: [ :create ], module: :users
    end

    # Events管理ルート（注目イベント更新アクションを含む）
    resources :events, only: [ :index, :edit, :update, :destroy ] do
      collection do
        # 注目イベントの更新は、部分的な更新のため PATCH メソッドが適切です。
        patch :update_event_features # /admin/events/update_event_features (PATCH)
      end
    end

    # Sellers管理ルート（コメント、編集可能トグル）
    resources :sellers, controller: "admin_sellers", only: [ :index, :show, :edit, :update ] do
      patch :toggle_editable, on: :member # /admin/sellers/:id/toggle_editable (PATCH)
      resources :comments, only: [ :create ], module: :sellers
    end

    # Hosts管理ルート（コメント、編集可能トグル、destroy）
    resources :hosts, controller: "admin_hosts", only: [ :index, :show, :edit, :update, :destroy ] do
      patch :toggle_editable, on: :member # /admin/hosts/:id/toggle_editable (PATCH)
      resources :comments, only: [ :create ], module: :hosts
    end

    # Notices管理ルート
    resources :notices
  end
  # --- ★★★ 管理者関連のルートはここまで移動 ★★★ ---

  # ==============================
  # グローバルなイベント一覧・詳細
  # ==============================
  resources :events do
    resources :event_likes, only: [:create, :destroy]
  end

  # ==============================
  # ホスト関連のカスタムルート (スラッグベースより先に定義)
  # ==============================
  get "hosts", to: "hosts#index", as: :hosts
  get "hosts/new", to: "hosts#new", as: :new_host
  post "hosts", to: "hosts#create", as: :create_host

  # ホストプロフィール編集・更新ルート (host_id を使う)
  get ":host_id/edit_profile", to: "hosts#edit", as: :edit_host_profile, constraints: { host_id: /[a-zA-Z0-9_-]+|\d+/ }
  patch ":host_id", to: "hosts#update", as: :update_host_profile, constraints: { host_id: /[a-zA-Z0-9_-]+|\d+/ }
  put ":host_id", to: "hosts#update", constraints: { host_id: /[a-zA-Z0-9_-]+|\d+/ }
  delete ":host_id", to: "hosts#destroy", as: :destroy_host_profile, constraints: { host_id: /[a-zA-Z0-9_-]+|\d+/ }

  # ==============================
  # ホストのネストされたイベント関連ルート
  # ==============================
  scope ":host_id", constraints: { host_id: /[a-zA-Z0-9_\-]+|\d+/ } do
    get "events/new", to: "hosts#new_event", as: :new_host_event
    post "events", to: "hosts#create_event", as: :host_events

    get "events/:id/edit", to: "hosts#edit_event", as: :edit_host_event
    patch "events/:id", to: "hosts#update_event", as: :update_host_event
    delete "events/:id", to: "hosts#destroy_event", as: :destroy_host_event
    get "events/:id", to: "hosts#show_event", as: :host_event
  end

  # ==============================
  # セラー関連のルート
  # ==============================
  resources :sellers, only: [ :index, :show, :edit, :update ] do
    resources :events, only: [ :new, :create ]
  end

  # ==============================
  # 施設関連のルート
  # ==============================
  resources :facilities, only: [ :index, :show ]
  resource :facility, only: [ :show, :new, :create, :edit, :update, :destroy ], controller: "facility"

  # ==============================
  # その他アプリケーション固有のルート
  # ==============================
  get "recruitment", to: "home#recruitment", as: "recruitment"

  # 新しい静的ページルート
  get "features", to: "home#features", as: "features" # 機能一覧
  get "pricing", to: "home#pricing", as: "pricing" # 利用料金について
  get "plan_comparison", to: "home#plan_comparison", as: "plan_comparison" # プラン比較
  get "flow", to: "home#flow", as: "flow" # 掲載までの流れ
  get "use_cases", to: "home#use_cases", as: "use_cases" # 利用事例
  get "terms", to: "home#terms", as: "terms" # 利用規約
  get "privacy", to: "home#privacy", as: "privacy" # プライバシーポリシー
  get "commercial_law", to: "home#commercial_law", as: "commercial_law" # 特定商取引法に基づく表示

  # ==============================
  # ★★★ 最重要: ホストのスラッグベースのプロフィールルート (最も汎用的なので最後に) ★★★
  # これが `/mimamoru-lab` のようなURLを処理します。
  # 他の固定パス（例: /about, /contact）との衝突を避けるため、
  # これらの固定パスより「後」に配置してください。
  # ==============================
  get ":id_or_slug", to: "hosts#show", as: :public_host_profile, constraints: { id_or_slug: /[a-zA-Z0-9_\-]+|\d+/ }

  # アプリケーションのルート
  root "home#index"

  # DevTools 関連のパス
  get "/.well-known/appspecific/com.chrome.devtools.json", to: proc { [ 404, {}, [ "Not Found" ] ] }
end
