class Event < ApplicationRecord
  include AsyncVariantGenerator
  VARIANT_ATTACHMENT_NAMES = [:images]
  VARIANT_COMMON_VARIANTS = [{ resize_to_limit: [800, 600] }, { resize_to_limit: [1200, 630] }]
  PREFECTURES = %w[
    北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県
    茨城県 栃木県 群馬県 埼玉県 千葉県 東京都 神奈川県
    新潟県 富山県 石川県 福井県 山梨県 長野県 岐阜県
    静岡県 愛知県 三重県 滋賀県 京都府 大阪府 兵庫県
    奈良県 和歌山県 鳥取県 島根県 岡山県 広島県 山口県
    徳島県 香川県 愛媛県 高知県 福岡県 佐賀県 長崎県
    熊本県 大分県 宮崎県 鹿児島県 沖縄県
  ].freeze

  PREFECTURE_CODES = PREFECTURES.each_with_index.to_h { |name, index| [index + 1, name] }.freeze

  ALLOWED_IMAGE_CONTENT_TYPES = %w[
    image/jpeg
    image/png
    image/gif
    image/webp
    image/heic
    image/heif
  ].freeze
  ALLOWED_IMAGE_EXTENSIONS = %w[
    .jpg
    .jpeg
    .png
    .gif
    .webp
    .heic
    .heif
  ].freeze
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
  scope :chronological, -> { order(start_time: :asc) }
  scope :upcoming, -> { where("start_time >= ?", Time.zone.now).chronological }

  def self.prefecture_counts
    prefecture_counts = where.not(prefecture: [nil, ""]).group(:prefecture).count
    venue_counts = where.not(venue: [nil, ""]).group(:venue).count

    prefecture_counts.merge(venue_counts) do |_prefecture, left_count, right_count|
      left_count.to_i + right_count.to_i
    end
  end

  def self.prefecture_summary
    counts = prefecture_counts

    PREFECTURES.map do |prefecture|
      {
        name: prefecture,
        count: counts.fetch(prefecture, 0),
        active: counts.key?(prefecture)
      }
    end
  end

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
      image_content_type = image.content_type.to_s.downcase
      filename_extension = File.extname(image.filename.to_s).downcase

      content_type_allowed = image_content_type.in?(ALLOWED_IMAGE_CONTENT_TYPES)
      extension_allowed = filename_extension.in?(ALLOWED_IMAGE_EXTENSIONS)

      !(content_type_allowed || extension_allowed)
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
