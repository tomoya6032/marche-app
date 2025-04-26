class Event < ApplicationRecord
  has_many_attached :images
  belongs_to :seller

  validate :images_content_type
  validate :images_size

  validates :title, presence: true
  validates :description, presence: true

  private

  def images_content_type
    if images.attached?
      images.each do |image|
        unless image.content_type.in?(%w[image/jpeg image/png image/gif])
          errors.add(:images, "\uFF1A\u30D5\u30A1\u30A4\u30EB\u5F62\u5F0F\u304C\u3001JPEG, PNG, GIF\u4EE5\u5916\u306B\u306A\u3063\u3066\u307E\u3059\u3002\u30D5\u30A1\u30A4\u30EB\u5F62\u5F0F\u3092\u3054\u78BA\u8A8D\u304F\u3060\u3055\u3044\u3002")
          break # 1つでもエラーがあればループを抜ける
        end
      end
    end
  end

  def images_size
    if images.attached?
      images.each do |image|
        if image.blob.byte_size > 100.megabytes
          errors.add(:images, "\uFF1A100MB\u4EE5\u4E0B\u306E\u30D5\u30A1\u30A4\u30EB\u3092\u30A2\u30C3\u30D7\u30ED\u30FC\u30C9\u3057\u3066\u304F\u3060\u3055\u3044\u3002")
          break # 1つでもエラーがあればループを抜ける
        end
      end
    end
  end
end
