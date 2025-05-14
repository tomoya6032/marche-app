class Good < ApplicationRecord
  belongs_to :host
  has_one_attached :image # 商品画像を添付可能にする

  validates :name, presence: true
  validates :description, presence: true
end
