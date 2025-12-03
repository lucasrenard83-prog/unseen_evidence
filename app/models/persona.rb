class Persona < ApplicationRecord
  belongs_to :room
  has_many :messages
  has_many :items
end
