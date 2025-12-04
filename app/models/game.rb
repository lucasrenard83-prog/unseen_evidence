class Game < ApplicationRecord
  belongs_to :user
  has_many :rooms,    dependent: :destroy
  has_many :items,    dependent: :destroy
  has_many :messages, dependent: :destroy
end
