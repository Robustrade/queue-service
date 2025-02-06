class MessageMetadatum < ApplicationRecord
  belongs_to :event

  # validates
  validates :key, :data_type, :required, :regex_validation, presence: true
end
