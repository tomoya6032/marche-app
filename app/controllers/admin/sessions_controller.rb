class Admin::SessionsController < Devise::SessionsController
  # ログイン後のリダイレクト先をカスタマイズ
  def after_sign_in_path_for(resource)
    admin_root_path # 管理者用のダッシュボードにリダイレクト
    '/administrator' # または administrator_dashboard_path (もし設定していれば)
  end

  # ログアウト後のリダイレクト先をカスタマイズ
  def after_sign_out_path_for(resource_or_scope)
    new_admin_session_path # 管理者ログインページにリダイレクト
  end

  # 必要に応じて他のアクションをオーバーライド可能
  # 例: ログイン時の追加処理
  # def create
  #   super
  #   # 追加の処理をここに記述
  # end
end
