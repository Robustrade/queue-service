FactoryBot.define do
  factory :message_received do
    event { nil }
    sender_unique_id { "MyString" }
    req_payload { "" }
    received_at { "2025-02-06 12:52:54" }
    worked_processed_at { "2025-02-06 12:52:54" }
    status_code { 1 }
    response_payload { "" }
    total_retries { 1 }
    enqueued_at { "2025-02-06 12:52:54" }
  end
end
