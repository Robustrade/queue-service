class RenameTypeColumnInMessageMetadata < ActiveRecord::Migration[8.0]
  def change
    rename_column :message_metadata, :type, :data_type
  end
end
