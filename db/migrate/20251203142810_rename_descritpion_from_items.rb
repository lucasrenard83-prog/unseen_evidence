class RenameDescritpionFromItems < ActiveRecord::Migration[7.1]
  def change
    rename_column :items, :descritption, :description
  end
end
