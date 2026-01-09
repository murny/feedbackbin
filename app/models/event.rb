# frozen_string_literal: true

class Event < ApplicationRecord
  include Event::Particulars
  include Notifiable

  belongs_to :account, default: -> { Current.account }
  belongs_to :board
  belongs_to :creator, class_name: "User"
  belongs_to :eventable, polymorphic: true

  # Make action queryable like: event.action.idea_published?
  def action
    super.inquiry
  end

  # Provide structured description for UI display
  def description_for(user)
    Event::Description.new(self, user)
  end

  # Hook that gets called after event creation, allowing eventables to respond
  after_create -> { eventable.event_was_created(self) if eventable.respond_to?(:event_was_created) }
end
