class Comment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :seller, optional: true
  belongs_to :host, optional: true
  belongs_to :admin, class_name: "Administrator", foreign_key: "admin_id"

  validates :body, presence: true
  validate :at_least_one_association_present

  private

  # user_id, seller_id, host_idのいずれかが必須
  def at_least_one_association_present
    if user_id.blank? && seller_id.blank? && host_id.blank?
      errors.add(:base, "user_id, seller_id, または host_id のいずれかを指定してください")
    end
  end
end
