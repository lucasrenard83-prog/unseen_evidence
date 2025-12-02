class AddOpenToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :open, :boolean
  end
end
