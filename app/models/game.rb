class Game < ApplicationRecord
  belongs_to :user
  has_many :messages
  has_many :rooms
end
