class ServiceOwner < ApplicationRecord
  has_many :events, dependent: :destroy

  # validates
  validates :name, :secret_token, presence: true
end
