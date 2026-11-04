class ContactForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :email, :string
  attribute :subject, :string
  attribute :message, :string

  validates :name, presence: { message: "お名前を入力してください。" }
  validates :email, presence: { message: "メールアドレスを入力してください。" }, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    message: "メールアドレスの形式が正しくありません。"
  }
  validates :subject, presence: { message: "お問い合わせ件名を入力してください。" }
  validates :message, presence: { message: "お問い合わせ内容を入力してください。" }
end
