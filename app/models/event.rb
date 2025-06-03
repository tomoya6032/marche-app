class Event < ApplicationRecord
  has_many_attached :images, dependent: :purge_later
  
  belongs_to :seller, optional: true # セラーとの関連
  belongs_to :host, optional: true   # ホストとの関連

  validate :images_content_type, :images_size

  validates :title, presence: true
  validates :description, presence: true
  paginates_per 5 # デフォルトで1ページに5件表示
  scope :featured, -> { where(is_featured: true) }

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
