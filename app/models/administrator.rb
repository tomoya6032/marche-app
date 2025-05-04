class Administrator < ApplicationRecord
# Devise モジュールを有効化
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
