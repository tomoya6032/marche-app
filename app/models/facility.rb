class Facility < ApplicationRecord
  has_many :events
  has_many :hosts
  has_many :sellers

  validates :name, presence: true
  validates :description, presence: true
  validates :address, presence: true
  validates :phone_number, presence: true
  validates :website, presence: true
end
