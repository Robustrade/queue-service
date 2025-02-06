class CreateServiceOwners < ActiveRecord::Migration[8.0]
  def change
    create_table :service_owners do |t|
      t.string :name
      t.string :email
      t.string :api_key
      t.string :secret_token

      t.timestamps
    end
  end
end
