# frozen_string_literal: true

module User::Avatar
  extend ActiveSupport::Concern

  ALLOWED_AVATAR_CONTENT_TYPES = %w[ image/jpeg image/png image/gif image/webp ].freeze

  included do
    has_one_attached :avatar do |attachable|
      attachable.variant :thumb, resize_to_fill: [ 256, 256 ], process: :immediately
    end

    validates :avatar, content_type: { in: ALLOWED_AVATAR_CONTENT_TYPES }, file_size: { maximum: 2.megabytes }
  end

  def avatar_thumbnail
    avatar.variable? ? avatar.variant(:thumb) : avatar
  end
end
