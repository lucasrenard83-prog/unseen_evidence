class Game < ApplicationRecord
  belongs_to :user
  has_many :messages
  has_many :rooms
  has_many :items
end
