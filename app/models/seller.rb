class Seller < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many_attached :images
  has_one_attached :image
  
  # 追加したカラムをモデルに反映
  attribute :name, :string
  attribute :description, :text
  attribute :address, :string
  validates :email, presence: true, uniqueness: true
  
  attribute :phone_number, :string
  attribute :website, :string
  
  attribute :image, :string
  attribute :video, :string

  # 営業時間
  attribute :business_hours_days, :string
  attribute :business_hours_start, :time
  attribute :business_hours_end, :time

  # 過去の出店実績
  attribute :past_exhibitions_names, :text
  attribute :past_exhibitions_dates, :text

  # SNSアカウント
  attribute :sns_accounts_types, :string
  attribute :sns_accounts_urls, :string

  # SNSアカウントのenum
   def self.sns_types
    { twitter: 0, instagram: 1, facebook: 2, tinder: 3 }
   end

  # SNSアカウントの選択肢
   def sns_types_for_select
    self.class.sns_types.keys.map { |k| [I18n.t("activerecord.attributes.seller.sns_type.#{k}"), k] }
   end

   def image_url
    image.present? ? image : "no_image_square.jpg" # デフォルトの画像ファイル名を指定
   end

  # SNSアカウントのバリデーション
  # validate :sns_accounts_types_and_urls_length

  private

  def sns_accounts_types_and_urls_length
    return unless sns_accounts_types.present? && sns_accounts_urls.present?

    types = sns_accounts_types.split(',')
    urls = sns_accounts_urls.split(',')

    errors.add(:sns_accounts_urls, 'SNSアカウントの種類とURLの数が一致しません') unless types.length == urls.length
  end

end
