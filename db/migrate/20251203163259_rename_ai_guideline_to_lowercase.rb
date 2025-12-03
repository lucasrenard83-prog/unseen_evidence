class RenameAiGuidelineToLowercase < ActiveRecord::Migration[7.1]
  def change
    rename_column :rooms, :AI_guideline, :ai_guideline
  end
end
