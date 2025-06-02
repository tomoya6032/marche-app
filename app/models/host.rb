class Host < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :facility, optional: true
  has_many :events, dependent: :destroy
  has_many :comments, dependent: :destroy
  # has_many :topics, dependent: :destroy # トピックスとの関連付け
  # has_many :news, dependent: :destroy # 新着ニュースとの関連付け

  has_one_attached :top_image # トップ画像
  has_many_attached :images # 複数画像を添付可能
  has_one_attached :video # 動画を添付可能

  has_one_attached :goods_image_1
  has_one_attached :goods_image_2
  has_one_attached :goods_image_3
  has_one_attached :goods_image_4

  # 追加したカラムをモデルに反映 (Seller モデルを参考に Host モデルに必要な属性を定義)
  attribute :name, :string
  attribute :description, :text
  attribute :address, :string
  validates :email, presence: true, uniqueness: true

  # validates :name, presence: true

  attribute :phone_number, :string
  attribute :website, :string

  attribute :image, :string
  attribute :video, :string

  # def self.ransackable_attributes(auth_object = {})
  #   ["address", "created_at", "description", "email", "id", "name", "news", "phone_number", "topics", "updated_at", "website", "goods_introduction"] # Ransack を使用している場合
  # end

  # protected

  # def self.ransackable_associations(auth_object = {})
  #   ["events", "images", "top_image", "video"] # Ransack を使用している場合
  # end

  # def self.ransackable_scopes(auth_object = {})
  #   []
  # end

  # def self.ransackable_sorts(auth_object = {})
  #   ["address", "created_at", "description", "email", "id", "name", "news", "phone_number", "topics", "updated_at", "website"] # Ransack を使用している場合
  # end

  # (必要に応じて) 営業時間
  attribute :business_hours_days, :string
  attribute :business_hours_start, :time
  attribute :business_hours_end, :time

  # (必要に応じて) 過去の主催実績
  attribute :past_exhibitions_names, :text
  attribute :past_exhibitions_dates, :text

  # (必要に応じて) SNSアカウント
  attribute :sns_accounts_types, :string
  attribute :sns_accounts_urls, :string

  # (必要に応じて) SNSアカウントの enum
  def self.sns_types
    { twitter: 0, instagram: 1, facebook: 2, tinder: 3 } # Seller モデルのものをそのまま流用。必要に応じて Host 固有のものに変更
  end

  # (必要に応じて) SNSアカウントの選択肢
  # def sns_types_for_select
  #   self.class.sns_types.keys.map { |k| [I18n.t("activerecord.attributes.host.sns_type.#{k}"), k] } # host 用の翻訳キーを使用
  #   self.class.sns_types.keys.map { |k| [I18n.t("activerecord.attributes.host.sns_type.#{k}"), k] } # host 用の翻訳キーを使用
  # end

  # def image_url
  # def image_urlnt?  image : "no_image_square.jpg" # デフォルトの画像ファイル名を指定
  #   image.present? ? image : "no_image_square.jpg" # デフォルトの画像ファイル名を指定
  # end
  # (必要に応じて) SNSアカウントのバリデーション
  # (必要に応じて) SNSアカウントのバリデーションpes_and_urls_length
  # validate :sns_accounts_types_and_urls_length
  private
  private
  # (必要に応じて) SNSアカウントのバリデーションメソッド
  # (必要に応じて) SNSアカウントのバリデーションメソッド_length
  # def sns_accounts_types_and_urls_lengthsent? & sns_accounts_urls.present?
  #   return unless sns_accounts_types.present? & sns_accounts_urls.present?
  #   types = sns_accounts_types.split(',')
  #   types = sns_accounts_types.split(',')
  #   urls = sns_accounts_urls.split(',')
  #   errors.add(:sns_accounts_urls, 'SNSアカウントの種類とURLの数が一致しません') unless types.length == urls.length
  #   errors.add(:sns_accounts_urls, 'SNSアカウントの種類とURLの数が一致しません') unless types.length == urls.length
  end