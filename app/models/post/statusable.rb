# frozen_string_literal: true

module Post::Statusable
  extend ActiveSupport::Concern

  included do
    belongs_to :post_status, default: -> { Current.organization&.default_post_status }

    scope :with_status, ->(status) { where(post_status: status) }
    scope :by_status, -> { joins(:post_status).order("post_statuses.position") }
  end

  def status
    post_status
  end

  def change_status(new_status, user: Current.user)
    transaction do
      update!(post_status: new_status)
      track_event(:status_changed, creator: user, particulars: {
        from_status: post_status_previously_was&.name,
        to_status: new_status.name
      })
    end
  end

  private
    # Helper to get the previous post_status value (for tracking status changes)
    def post_status_previously_was
      PostStatus.find_by(id: post_status_id_previously_was) if post_status_id_previously_was
    end
end
