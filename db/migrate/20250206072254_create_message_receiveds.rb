class CreateMessageReceiveds < ActiveRecord::Migration[8.0]
  def change
    create_table :message_receiveds do |t|
      t.references :event, null: false, foreign_key: true
      t.string :sender_unique_id
      t.json :req_payload
      t.datetime :received_at
      t.datetime :worked_processed_at
      t.integer :status_code
      t.json :response_payload
      t.integer :total_retries
      t.datetime :enqueued_at

      t.timestamps
    end
  end
end
