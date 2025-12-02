class AddPositionToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :position, :integer
  end
end
