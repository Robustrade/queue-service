FactoryBot.define do
  factory :message_metadatum do
    event { nil }
    key { "MyString" }
    type { "" }
    required { false }
    regex_validation { "MyString" }
  end
end
