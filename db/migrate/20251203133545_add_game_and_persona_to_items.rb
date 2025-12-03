class AddGameAndPersonaToItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :items, :game, null: true, foreign_key: true
    add_reference :items, :persona, null: true, foreign_key: true
  end
end
