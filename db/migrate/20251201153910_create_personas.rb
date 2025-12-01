class CreatePersonas < ActiveRecord::Migration[7.1]
  def change
    create_table :personas do |t|
      t.string :name
      t.string :public_description
      t.string :secret_description
      t.boolean :guilty
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
