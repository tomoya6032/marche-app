class SiteSetting < ApplicationRecord
  # バリデーション
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

  # シングルトンパターン: 設定は1レコードのみ
  def self.instance
    first_or_create
  end

  # 問い合わせメールアドレスを取得（デフォルト値付き）
  def self.contact_email
    instance.contact_email.presence || 'mimamorilab@gmail.com'
  end
end
