class MakePersonaOptionalOnMessages < ActiveRecord::Migration[7.1]
  def change
    change_column_null :messages, :persona_id, true
  end
end
