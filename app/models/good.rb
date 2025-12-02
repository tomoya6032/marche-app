class Good < ApplicationRecord
  belongs_to :host
  has_one_attached :image # 商品画像を添付可能にする

  include AsyncVariantGenerator
  VARIANT_ATTACHMENT_NAMES = [:image]
  VARIANT_COMMON_VARIANTS = [{ resize_to_limit: [800, 600] }]

  validates :name, presence: true
  validates :description, presence: true
end
