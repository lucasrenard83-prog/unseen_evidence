class RenameDescritpionFromPersona < ActiveRecord::Migration[7.1]
  def change
    rename_column :personas, :descritption, :description
  end
end
