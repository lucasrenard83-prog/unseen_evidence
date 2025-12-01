class Room < ApplicationRecord
  belongs_to :game
  has_many :messages
  has_many :personas
  has_many :items
end
