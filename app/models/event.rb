# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to :organization, default: -> { Current.organization }
  belongs_to :eventable, polymorphic: true

  scope :ordered, -> { order(created_at: :desc) }
  scope :for_organization, ->(organization) { where(organization: organization) }
  scope :for_eventable, ->(eventable) { where(eventable: eventable) }
  scope :by_action, ->(action) { where(action: action) }
  scope :recent, -> { ordered.limit(50) }

  validates :action, presence: true

  # Class method to cleanup old events (older than 90 days)
  # Called by recurring job
  def self.cleanup_old(older_than: 90.days.ago)
    where("created_at < ?", older_than).delete_all
  end
end
