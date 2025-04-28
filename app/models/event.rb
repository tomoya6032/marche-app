class Event < ApplicationRecord
  has_many_attached :images
  belongs_to :seller

  validate :images_content_type, :images_size

  validates :title, presence: true
  validates :description, presence: true

  private

  def images_content_type
    return unless images.attached?

    invalid_images = images.select do |image|
      !image.content_type.in?(%w[image/jpeg image/png image/gif])
    end

    if invalid_images.any?
      errors.add(:images, I18n.t('errors.messages.invalid_image_format'))
    end
  end

  def images_size
    return unless images.attached?

    oversized_images = images.select do |image|
      image.blob.byte_size > 100.megabytes
    end

    if oversized_images.any?
      errors.add(:images, I18n.t('errors.messages.image_too_large'))
    end
  end
end
