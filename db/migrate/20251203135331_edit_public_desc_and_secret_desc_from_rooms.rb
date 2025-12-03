class EditPublicDescAndSecretDescFromRooms < ActiveRecord::Migration[7.1]
  def change
    rename_column :rooms, :public_description, :descritption
    rename_column :rooms, :secret_description, :ai_guideline
  end
end
