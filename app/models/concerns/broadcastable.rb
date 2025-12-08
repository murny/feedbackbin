# frozen_string_literal: true

# Broadcastable concern for Turbo Stream broadcasts
#
# This concern provides real-time updates to connected clients when records change.
# Models that include this concern will automatically broadcast Turbo Stream refreshes
# when they are created, updated, or destroyed.
#
# Example usage in a model:
#   include Broadcastable
#
# For custom broadcast targets, override broadcast_targets in your model:
#   def broadcast_targets
#     [self, organization, :all_posts]
#   end
module Broadcastable
  extend ActiveSupport::Concern

  included do
    broadcasts_refreshes
    after_commit :broadcast_to_custom_targets, if: -> { respond_to?(:broadcast_targets) }
  end

  private
    def broadcast_to_custom_targets
      return unless respond_to?(:broadcast_targets)

      broadcast_targets.each do |target|
        broadcast_refresh_to(target)
      end
    end
end
