class EditPublicDescAndSecretDescFromPersona < ActiveRecord::Migration[7.1]
  def change
    rename_column :personas, :public_description, :description
    rename_column :personas, :secret_description, :ai_guideline
  end
end
