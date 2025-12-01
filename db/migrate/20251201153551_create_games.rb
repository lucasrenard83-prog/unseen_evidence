class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.references :user, null: false, foreign_key: true
      t.string :scenario
      t.string :secret_scenario

      t.timestamps
    end
  end
end
