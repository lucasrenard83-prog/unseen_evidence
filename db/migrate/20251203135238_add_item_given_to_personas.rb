class AddItemGivenToPersonas < ActiveRecord::Migration[7.1]
  def change
    add_column :personas, :item_given, :boolean
  end
end
