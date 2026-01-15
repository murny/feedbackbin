# frozen_string_literal: true

class Account < ApplicationRecord
  include Searchable

  ALLOWED_IMAGE_CONTENT_TYPES = %w[ image/jpeg image/png image/gif image/webp ].freeze

  # Generate external_account_id before create if not set
  before_create :assign_external_account_id, unless: :external_account_id?

  # Attachments
  has_one_attached :logo
  has_one_attached :favicon
  has_one_attached :og_image

  has_many :webhook_delinquency_trackers, class_name: "Webhook::DelinquencyTracker", dependent: :destroy
  has_many :webhooks, dependent: :destroy
  has_many :watches, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :changelogs, dependent: :destroy
  has_many :ideas, dependent: :destroy
  has_many :boards, dependent: :destroy
  has_many :statuses, dependent: :destroy
  has_many :users, dependent: :destroy

  validates :logo, content_type: { in: ALLOWED_IMAGE_CONTENT_TYPES }, file_size: { maximum: 2.megabytes }
  validates :favicon, content_type: { in: ALLOWED_IMAGE_CONTENT_TYPES }, file_size: { maximum: 500.kilobytes }
  validates :og_image, content_type: { in: ALLOWED_IMAGE_CONTENT_TYPES }, file_size: { maximum: 2.megabytes }
  validates :logo_link, url: { allow_blank: true }
  validates :name, presence: true

  def self.create_with_owner(account:, owner:)
    create!(**account).tap do |account|
      account.users.create!(role: :system, name: "System")
      account.users.create!(**owner.reverse_merge(role: :owner, verified_at: Time.current))
    end
  end

  def system_user
    users.find_by!(role: :system)
  end

  # Check if user is the owner
  def owned_by?(user)
    user&.owner?
  end

  # Allow `record.account` to work when record IS an Account (e.g., for attachments)
  def account
    self
  end

  # Returns the path prefix slug for this account (e.g., "/1234567")
  def slug
    AccountSlug.encode(external_account_id)
  end

  private

    def assign_external_account_id
      self.external_account_id = ExternalIdSequence.next
    end
end
