# frozen_string_literal: true

class Event < ApplicationRecord
  include Event::Particulars
  include Notifiable

  belongs_to :account, default: -> { board.account }
  belongs_to :board
  belongs_to :creator, class_name: "User"
  belongs_to :eventable, polymorphic: true

  has_many :webhook_deliveries, class_name: "Webhook::Delivery", dependent: :destroy

  # Callbacks
  after_create -> { eventable.event_was_created(self) if eventable.respond_to?(:event_was_created) }
  after_create_commit :dispatch_webhooks

  # Make action queryable like: event.action.idea_published?
  def action
    super.inquiry
  end

  # Provide structured description for UI display
  def description_for(user)
    Event::Description.new(self, user)
  end

  private

  # Dispatch webhooks for this event
  def dispatch_webhooks
    Webhook::DispatchJob.perform_later(self)
  end
end
