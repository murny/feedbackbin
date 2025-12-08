# frozen_string_literal: true

class Comment < ApplicationRecord
  include Likeable
  include Eventable
  include Broadcastable
  include Comment::Threadable

  belongs_to :creator, class_name: "User", default: -> { Current.user }
  belongs_to :post, counter_cache: true, touch: true

  has_rich_text :body

  validates :body, presence: true

  scope :ordered, -> { order(created_at: :asc) }

  # Track events for comment lifecycle
  after_create_commit -> { track_event(:created, creator: creator) }
  # Note: body is a rich_text, so we can't easily track changes to it
  # after_update_commit -> { track_event(:updated, creator: creator) }
  before_destroy -> { track_event(:deleted, creator: Current.user || Current.organization&.system_user) }

  # Broadcast to the post when comments change
  def broadcast_targets
    [post]
  end
end
