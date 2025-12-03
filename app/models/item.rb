class Item < ApplicationRecord
  belongs_to :room
  belongs_to :game
  belongs_to :persona
end
