class RenameEditSearchFromRooms < ActiveRecord::Migration[7.1]
  def change
    rename_column :rooms, :searched, :item_found
  end
end
