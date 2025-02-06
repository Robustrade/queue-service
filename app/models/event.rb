class Event < ApplicationRecord
  belongs_to :service_owner
  has_many :message_metadata, dependent: :destroy
  has_many :message_receiveds, dependent: :destroy
end
