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

  validates :logo, resizable_image: true, max_file_size: 2.megabytes
  validates :favicon, resizable_image: true, max_file_size: 500.kilobytes
  validates :og_image, resizable_image: true, max_file_size: 2.megabytes
  validates :logo_link, url: { allow_blank: true }
  validates :name, presence: true
  validate :owner_must_be_administrator

  # Check if user is the owner
  def owned_by?(user)
    owner == user
  end

  private

    def owner_must_be_administrator
      if owner && !owner.administrator?
        errors.add(:owner, :must_be_administrator)
      end
    end
end
