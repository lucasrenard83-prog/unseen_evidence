class RemoveGuiltyFromPersonas < ActiveRecord::Migration[7.1]
  def change
    remove_column :personas, :guilty, :boolean
  end
end
