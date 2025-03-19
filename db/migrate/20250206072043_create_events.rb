class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :name
      t.string :callback_url
      t.references :service_owner, null: false, foreign_key: true

      t.timestamps
    end
  end
end
