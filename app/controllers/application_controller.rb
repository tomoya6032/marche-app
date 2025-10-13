class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  # Devise のヘルパーメソッドを使用可能にする
  include Devise::Controllers::Helpers
  include MetaTags::ControllerHelper

  helper_method :seller_signed_in?, :host_signed_in?, :current_host, :current_seller

  # パフォーマンス最適化: current_userを一度だけ読み込み
  def current_seller
    @current_seller ||= super
  end

  def current_host
    @current_host ||= super
  end

  def seller_signed_in?
    super
  end

  def host_signed_in?
    super
  end

  def destroy
    sign_out current_seller # セッションからセラーを削除
    redirect_to root_path, notice: "\u30ED\u30B0\u30A2\u30A6\u30C8\u3057\u307E\u3057\u305F\u3002" # ログアウト後にトップページに遷移
  end
end
