class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  attr_accessor :admin_comments # 仮想属性を追加

  has_many :comments, dependent: :destroy # コメントとの関連付け

  # 会員区分を定義（コメントアウト）
  # enum membership_type: { seller: 0, host: 1 }, _prefix: :membership

  # 無料期間が終了しているかを判定
  def trial_expired?
    trial_end_date && trial_end_date < Date.today
  end

  # 管理者かどうかを判定
  def admin?
    role == "admin" # roleカラムが"admin"の場合に管理者と判定
  end
end
