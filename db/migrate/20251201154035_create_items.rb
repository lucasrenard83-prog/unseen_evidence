class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :name
      t.string :descritption
      t.references :room, null: false, foreign_key: true
      t.string :picture_url
      t.boolean :found
      t.string :kind

      t.timestamps
    end
  end
end
