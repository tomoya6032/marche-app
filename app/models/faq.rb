# app/models/faq.rb

class Faq < ApplicationRecord
  validates :question, presence: true, length: { maximum: 255 }
  # note_url が正しいURL形式であるか検証
  validates :note_url, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  validates :order, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # デフォルトの並び順を設定（orderカラムの昇順）
  # default_scope { order(:order) }  # 一旦コメントアウト
end
