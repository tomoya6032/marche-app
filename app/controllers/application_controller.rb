class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

# Devise のヘルパーメソッドを使用可能にする
  include Devise::Controllers::Helpers
  include MetaTags::ControllerHelper
  
  helper_method :seller_signed_in?, :host_signed_in?, :current_host

  def seller_signed_in?
    super
  end

  def host_signed_in?
    super
  end

  def destroy
    sign_out current_seller # セッションからセラーを削除
    redirect_to root_path, notice: 'ログアウトしました。' # ログアウト後にトップページに遷移 
  end
end