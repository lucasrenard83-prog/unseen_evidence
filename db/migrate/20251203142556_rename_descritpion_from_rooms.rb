class RenameDescritpionFromRooms < ActiveRecord::Migration[7.1]
  def change
    rename_column :rooms, :descritption, :description
  end
end
