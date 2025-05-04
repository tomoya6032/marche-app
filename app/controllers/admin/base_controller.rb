class Admin::BaseController < ApplicationController
  before_action :authenticate_administrator! # Deviseの認証を一括管理

  def after_sign_in_path_for(resource)
    if resource.is_a?(Admin)
      admin_root_path # 管理者用のダッシュボードにリダイレクト
    else
      super
    end
  end

  rescue_from Devise::MissingWarden do
    redirect_to new_admin_session_path, alert: "\u7BA1\u7406\u8005\u3068\u3057\u3066\u30ED\u30B0\u30A4\u30F3\u3057\u3066\u304F\u3060\u3055\u3044\u3002"
  end
end
