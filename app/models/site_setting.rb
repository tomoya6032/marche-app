class SiteSetting < ApplicationRecord
  # バリデーション
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

  # シングルトンパターン: 設定は1レコードのみ
  def self.instance
    first_or_create
  end

  def self.supports_trial_period_expired_notice?
    column_names.include?("show_trial_period_expired_notice")
  end

  def show_trial_period_expired_notice?
    return true unless self.class.supports_trial_period_expired_notice?

    self[:show_trial_period_expired_notice].nil? ? true : self[:show_trial_period_expired_notice]
  end

  def self.show_trial_period_expired_notice?
    instance.show_trial_period_expired_notice?
  end

  # 問い合わせメールアドレスを取得（デフォルト値付き）
  def self.contact_email
    instance.contact_email.presence || 'mimamorilab@gmail.com'
  end
end
