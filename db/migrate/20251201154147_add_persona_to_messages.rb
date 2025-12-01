class AddPersonaToMessages < ActiveRecord::Migration[7.1]
  def change
    add_reference :messages, :persona, null: false, foreign_key: true
  end
end
