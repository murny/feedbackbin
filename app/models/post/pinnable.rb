# frozen_string_literal: true

module Post::Pinnable
  extend ActiveSupport::Concern

  included do
    scope :pinned, -> { where(pinned: true) }
    scope :unpinned, -> { where(pinned: false) }
    scope :ordered_with_pinned, -> { order(pinned: :desc, created_at: :desc) }
  end

  def pinned?
    pinned
  end

  def pin!
    update!(pinned: true)
  end

  def unpin!
    update!(pinned: false)
  end
end
