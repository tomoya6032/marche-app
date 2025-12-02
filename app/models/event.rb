class Event < ApplicationRecord
  include AsyncVariantGenerator
  VARIANT_ATTACHMENT_NAMES = [:images]
  VARIANT_COMMON_VARIANTS = [{ resize_to_limit: [800, 600] }, { resize_to_limit: [1200, 630] }]
  has_many_attached :images, dependent: :purge_later
  has_many :event_views, dependent: :destroy
  has_many :event_likes, dependent: :destroy

  belongs_to :seller, optional: true # セラーとの関連
  belongs_to :host, optional: true   # ホストとの関連

  validate :images_content_type, :images_size

  validates :title, presence: true
  validates :description, presence: true
  paginates_per 5 # デフォルトで1ページに5件表示
  scope :featured, -> { where(is_featured: true) }

  # 直近1週間で閲覧数の多いイベントを取得（画像のみpreload）
  scope :popular_this_week, ->(limit = 3) {
    joins(:event_views)
      .includes(images_attachments: :blob)
      .where(event_views: { viewed_at: 1.week.ago..Time.current })
      .group("events.id")
      .select("events.*, COUNT(event_views.id) as views_count_this_week")
      .order("COUNT(event_views.id) DESC")
      .limit(limit)
  }

  # キャッシュ機能付きの人気イベント取得
  def self.cached_popular_this_week(limit = 3)
    Rails.cache.fetch("popular_events_week_#{Date.current}", expires_in: 10.minutes) do
      popular_this_week(limit).to_a
    end
  end

  # 直近1週間の閲覧数を取得（scope結果を優先）
  def views_count_this_week
    # scope結果にviews_count_this_week属性がある場合はそれを使用
    if respond_to?(:read_attribute) && has_attribute?(:views_count_this_week)
      read_attribute(:views_count_this_week)
    else
      event_views.where(viewed_at: 1.week.ago..Time.current).count
    end
  end

  # 総閲覧数を取得
  def total_views_count
    event_views.count
  end

  private

  def images_content_type
    return unless images.attached?

    invalid_images = images.select do |image|
      !image.content_type.in?(%w[image/jpeg image/png image/gif])
    end

    if invalid_images.any?
      errors.add(:images, I18n.t("errors.messages.invalid_image_format"))
    end
  end

  def images_size
    return unless images.attached?

    oversized_images = images.select do |image|
      image.blob.byte_size > 100.megabytes
    end

    if oversized_images.any?
      errors.add(:images, I18n.t("errors.messages.image_too_large"))
    end
  end

  def image_url
    images.attached? ? Rails.application.routes.url_helpers.rails_blob_url(images.first, only_path: true) : nil
  end
end
