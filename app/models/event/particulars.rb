# frozen_string_literal: true

# Particulars provides dynamic accessors for event metadata stored in the JSON column.
# This allows for flexible, event-specific data storage without needing additional columns.
#
# Example usage:
#   event = Event.create!(
#     action: "idea_status_changed",
#     particulars: { old_status: "Open", new_status: "In Progress" }
#   )
#
#   event.old_status  # => "Open"
#   event.new_status  # => "In Progress"
module Event::Particulars
  extend ActiveSupport::Concern

  # Provide dynamic read access to particulars data
  # e.g., event.old_title, event.assignee_ids, etc.
  def method_missing(method_name, *args, &block)
    if particulars.key?(method_name.to_s)
      particulars[method_name.to_s]
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    particulars.key?(method_name.to_s) || super
  end
end
