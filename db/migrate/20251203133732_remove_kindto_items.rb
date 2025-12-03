class RemoveKindtoItems < ActiveRecord::Migration[7.1]
  def change
    remove_column :items, :kind, :string
  end
end
