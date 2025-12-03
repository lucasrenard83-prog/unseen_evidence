class FixColumnTypos < ActiveRecord::Migration[7.1]
  def change
    # Fix typo: descritption -> description
    rename_column :rooms, :descritption, :description
    rename_column :personas, :descritption, :description
    rename_column :items, :descritption, :description

    # Fix typo: ai_guideline -> AI_guideline (for rooms)
    rename_column :rooms, :ai_guideline, :AI_guideline
  end
end
