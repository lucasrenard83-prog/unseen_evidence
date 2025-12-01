class CreateRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :rooms do |t|
      t.string :name
      t.string :public_description
      t.string :secret_description
      t.string :before_picture_url
      t.string :after_picture_url
      t.boolean :searched
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
