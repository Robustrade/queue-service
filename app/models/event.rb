class Event < ApplicationRecord
  belongs_to :service_owner
  has_many :message_metadata, class_name: 'MessageMetadatum', dependent: :destroy
  has_many :message_receiveds, dependent: :destroy

  # validates
  validates :name, :callback_url, presence: true
end
