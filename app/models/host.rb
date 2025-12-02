class Host < ApplicationRecord
  include AsyncVariantGenerator
  VARIANT_ATTACHMENT_NAMES = [:top_image, :images, :goods_image_1, :goods_image_2, :goods_image_3, :goods_image_4]
  VARIANT_COMMON_VARIANTS = [{ resize_to_limit: [800, 600] }]
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :facility, optional: true
  has_many :events, dependent: :destroy
  has_many :comments, dependent: :destroy
  # has_many :topics, dependent: :destroy # トピックスとの関連付け
  # has_many :news, dependent: :destroy # 新着ニュースとの関連付け

  # スラッグのバリデーション
  # slugはnullを許容し、存在する場合のみユニークであることを確認。
  # 形式も、slugが存在する場合のみチェック。
  validates :slug, uniqueness: { allow_nil: true },
                   format: { with: /\A[a-z0-9-]+\z/, message: "は半角英数字とハイフンのみ使用できます", allow_blank: true }
  validates :name, presence: true

  # ★★★ important: `before_validation :set_slug, on: :create` の行を削除またはコメントアウト ★★★
  
  
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

  def to_param
    slug.presence || id.to_s # slug があればそれを使う。なければデフォルトの id を使う
  end

  private
  
  def set_slug
    # 自動生成が必要な場合のみスラッグを生成
    # 例: name があり、かつ slug がまだ設定されていない場合
    # もし name から自動生成したいなら、このロジックは残し、
    # ユーザーが明示的に空白にしたい場合は set_slug をスキップするようなロジックが必要
    return if slug.present? || name.blank? # nameがない、またはslugが既にあるなら何もしない

    base_slug = name.parameterize
    suffix = 1
    # スラッグが既存でないかチェックし、重複していればsuffixを追加
    while Host.exists?(slug: base_slug)
      base_slug = "#{name.parameterize}-#{suffix}"
      suffix += 1
    end
    self.slug = base_slug
  end

 

end