class Message < ApplicationRecord
  belongs_to :game
  belongs_to :room
  has_many :personas
end
