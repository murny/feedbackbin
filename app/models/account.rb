# frozen_string_literal: true

class Account < ApplicationRecord
  include Searchable

  ALLOWED_IMAGE_CONTENT_TYPES = %w[ image/jpeg image/png image/gif image/webp ].freeze

  # Attachments
  has_one_attached :logo
  has_one_attached :favicon
  has_one_attached :og_image

  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :ideas, dependent: :destroy
  has_many :boards, dependent: :destroy
  has_many :changelogs, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :statuses, dependent: :destroy

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
