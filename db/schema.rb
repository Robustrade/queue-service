# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 20_250_206_140_654) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'pg_catalog.plpgsql'

  create_table 'events', force: :cascade do |t|
    t.string 'name'
    t.string 'callback_url'
    t.bigint 'service_owner_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['service_owner_id'], name: 'index_events_on_service_owner_id'
  end

  create_table 'message_metadata', force: :cascade do |t|
    t.bigint 'event_id', null: false
    t.string 'key'
    t.string 'data_type'
    t.boolean 'required'
    t.string 'regex_validation'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['event_id'], name: 'index_message_metadata_on_event_id'
  end

  create_table 'message_receiveds', force: :cascade do |t|
    t.bigint 'event_id', null: false
    t.string 'sender_unique_id'
    t.json 'req_payload'
    t.datetime 'received_at'
    t.datetime 'worked_processed_at'
    t.integer 'status_code'
    t.json 'response_payload'
    t.integer 'total_retries'
    t.datetime 'enqueued_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'error_message'
    t.json 'error_response'
    t.index ['event_id'], name: 'index_message_receiveds_on_event_id'
  end

  create_table 'service_owners', force: :cascade do |t|
    t.string 'name'
    t.string 'email'
    t.string 'api_key'
    t.string 'secret_token'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_foreign_key 'events', 'service_owners'
  add_foreign_key 'message_metadata', 'events'
  add_foreign_key 'message_receiveds', 'events'
end
