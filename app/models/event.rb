class Event < ApplicationRecord
   # belongs_to :facility # facilityとの関連付けを削除
   # 必要に応じて他の関連付けやバリデーションも修正
   # belongs_to :category
   has_many_attached :images

   validate :images_content_type
   validate :images_size

   
   validates :title, presence: true
   validates :description, presence: true
   
   # belongs_to :region #都道府県のバリデーションに関する記述

   # attribute :region, :string
   
   def images_content_type
      if images.attached?
        images.each do |image|
          unless image.content_type.in?(%w[image/jpeg image/png image/gif])
            errors.add(:images, '：ファイル形式が、JPEG, PNG, GIF以外になってます。ファイル形式をご確認ください。')
            break # 1つでもエラーがあればループを抜ける
          end
        end
      end
    end
  
    def images_size
      if images.attached?
        images.each do |image|
          if image.blob.byte_size > 10.megabytes
            errors.add(:images, '：1MB以下のファイルをアップロードしてください。')
            break # 1つでもエラーがあればループを抜ける
          end
        end
      end
    end

end
