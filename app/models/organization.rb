# frozen_string_literal: true

class Organization < ApplicationRecord
  include Domainable
  include Searchable

  # Attachments
  has_one_attached :logo
  has_one_attached :favicon
  has_one_attached :og_image

  belongs_to :default_post_status, class_name: "PostStatus"
  belongs_to :owner, class_name: "User"

  # Enums
  enum :logo_display_mode, {
    logo_and_name: "logo_and_name",
    logo_only: "logo_only"
  }, default: :logo_and_name

  validates :logo, resizable_image: true, max_file_size: 2.megabytes
  validates :favicon, resizable_image: true, max_file_size: 500.kilobytes
  validates :og_image, resizable_image: true, max_file_size: 2.megabytes
  validates :logo_link, url: { allow_blank: true, allow_relative: true }
  validates :logo_display_mode, presence: true
  validates :name, presence: true
  validate :owner_must_be_administrator

  # Check if user is the owner
  def owned_by?(user)
    owner == user
  end

  # Logo display helpers
  def show_logo_and_name?
    logo_and_name?
  end

  def show_logo_only?
    logo_only?
  end

  # Logo link URL (falls back to root path if not set)
  def logo_link_url
    logo_link.presence || "/"
  end

  # Open Graph image URL (fallback to logo if not set)
  def og_image_url
    if og_image.attached?
      Rails.application.routes.url_helpers.url_for(og_image)
    elsif logo.attached?
      Rails.application.routes.url_helpers.url_for(logo)
    else
      # Fallback to default icon
      "/icon.png"
    end
  end

  private

    def owner_must_be_administrator
      if owner && !owner.administrator?
        errors.add(:owner, :must_be_administrator)
      end
    end
end
