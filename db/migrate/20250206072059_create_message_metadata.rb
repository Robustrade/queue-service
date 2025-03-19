class CreateMessageMetadata < ActiveRecord::Migration[8.0]
  def change
    create_table :message_metadata do |t|
      t.references :event, null: false, foreign_key: true
      t.string :key
      t.string :type
      t.boolean :required
      t.string :regex_validation

      t.timestamps
    end
  end
end
