class Message < ApplicationRecord
  belongs_to :game
  belongs_to :room
  belongs_to :persona, optional: true
  validates :content, presence: true
end
