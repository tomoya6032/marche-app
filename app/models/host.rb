class Host < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :facility, optional: true
  has_many :events
  has_many :comments, dependent: :destroy

  has_one_attached :top_image # トップ画像
  has_many_attached :images # 活動風景や施設の外観の画像

  # 追加したカラムをモデルに反映 (Seller モデルを参考に Host モデルに必要な属性を定義)
  attribute :name, :string
  attribute :description, :text
  attribute :address, :string
  validates :email, presence: true, uniqueness: true

  validates :name, presence: true

  attribute :phone_number, :string
  attribute :website, :string

  attribute :image, :string
  attribute :video, :string

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
  def sns_types_for_select
    self.class.sns_types.keys.map { |k| [I18n.t("activerecord.attributes.host.sns_type.#{k}"), k] } # host 用の翻訳キーを使用
  end

  def image_url
    image.present? ? image : "no_image_square.jpg" # デフォルトの画像ファイル名を指定
  end

  # (必要に応じて) SNSアカウントのバリデーション
  # validate :sns_accounts_types_and_urls_length

  private

  # (必要に応じて) SNSアカウントのバリデーションメソッド
  def sns_accounts_types_and_urls_length
    return unless sns_accounts_types.present? && sns_accounts_urls.present?

    types = sns_accounts_types.split(',')
    urls = sns_accounts_urls.split(',')

    errors.add(:sns_accounts_urls, 'SNSアカウントの種類とURLの数が一致しません') unless types.length == urls.length
  end
end