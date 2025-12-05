class Persona < ApplicationRecord
  belongs_to :room
  has_many :messages, dependent: :destroy
  has_many :items, dependent: :destroy
end
