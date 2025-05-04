class Admin::RegistrationsController < Devise::RegistrationsController
  # サインアップ後のリダイレクト先をカスタマイズ
  def after_sign_up_path_for(resource)
    admin_root_path # 管理者用のダッシュボードにリダイレクト
  end

  # 必要に応じて他のアクションをオーバーライド可能
  # 例: サインアップ時の追加処理
  # def create
  #   super
  #   # 追加の処理をここに記述
  # end
end
