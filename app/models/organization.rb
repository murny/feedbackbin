# frozen_string_literal: true

class Organization < ApplicationRecord
  include Domainable
  include Searchable

  has_one_attached :logo

  belongs_to :default_post_status, class_name: "PostStatus"
  belongs_to :owner, class_name: "User"

  validates :logo, resizable_image: true, max_file_size: 2.megabytes
  validates :name, presence: true
  validate :owner_must_be_administrator

  # Check if user is the owner
  def owned_by?(user)
    owner == user
  end

  # Get or create the system user for this organization
  # System users are used for automated actions (cleanup jobs, auto-close, etc.)
  def system_user
    @system_user ||= begin
      User.find_or_create_by!(
        role: :system,
        username: "system_#{subdomain}"
      ) do |user|
        user.name = "FeedbackBin System"
        user.email_address = "system@#{subdomain}.feedbackbin.localhost"
        user.password = SecureRandom.hex(32)
        user.email_verified = true
        user.active = false  # System users don't need to be "active" in the traditional sense
      end
    rescue ActiveRecord::RecordInvalid
      # If the system user already exists (e.g., from fixtures or previous run), find it
      User.find_by!(role: :system, username: "system_#{subdomain}")
    end
  end

  private

    def owner_must_be_administrator
      if owner && !owner.administrator?
        errors.add(:owner, :must_be_administrator)
      end
    end
end
