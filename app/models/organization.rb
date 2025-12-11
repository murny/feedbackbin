# frozen_string_literal: true

class Organization < ApplicationRecord
  include Domainable
  include Searchable

  ALLOWED_IMAGE_CONTENT_TYPES = %w[ image/jpeg image/png image/gif image/webp ].freeze

  # Attachments
  has_one_attached :logo
  has_one_attached :favicon
  has_one_attached :og_image

  belongs_to :default_post_status, class_name: "PostStatus"

  validates :logo, content_type: { in: ALLOWED_IMAGE_CONTENT_TYPES }, file_size: { maximum: 2.megabytes }
  validates :favicon, content_type: { in: ALLOWED_IMAGE_CONTENT_TYPES }, file_size: { maximum: 500.kilobytes }
  validates :og_image, content_type: { in: ALLOWED_IMAGE_CONTENT_TYPES }, file_size: { maximum: 2.megabytes }
  validates :logo_link, url: { allow_blank: true }
  validates :name, presence: true

  # Check if user is the owner
  def owned_by?(user)
    user&.owner?
  end
end
