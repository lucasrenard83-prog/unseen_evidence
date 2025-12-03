class Item < ApplicationRecord
  belongs_to :room, optional: true
  belongs_to :game, optional: true
  belongs_to :persona, optional: true
  # validate :room_or_persona_present

  #  def room_or_persona_present
  #   if room.nil? && persona.nil?
  #     errors.add(:base, "Item must belong to a room or a persona")
  #   end
  # end
end
