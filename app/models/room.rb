class Room < ApplicationRecord
  belongs_to :game
  has_many :messages, dependent: :destroy
  has_many :personas, dependent: :destroy
  has_many :items, dependent: :destroy
end
