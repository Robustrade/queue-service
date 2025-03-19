class MessageReceived < ApplicationRecord
  belongs_to :event

  after_initialize :set_defaults, unless: :persisted?

  private

  def set_defaults
    self.total_retries ||= 0
  end
end
