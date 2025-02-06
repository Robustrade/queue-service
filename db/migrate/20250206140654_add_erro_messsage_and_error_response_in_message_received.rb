class AddErroMesssageAndErrorResponseInMessageReceived < ActiveRecord::Migration[8.0]
  def change
    add_column :message_receiveds, :error_message, :string
    add_column :message_receiveds, :error_response, :json
  end
end
