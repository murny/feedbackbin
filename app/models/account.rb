# frozen_string_literal: true

class Account < ApplicationRecord
  include Domainable
  include Searchable

  ALLOWED_IMAGE_CONTENT_TYPES = %w[ image/jpeg image/png image/gif image/webp ].freeze

  # Attachments
  has_one_attached :logo
  has_one_attached :favicon
  has_one_attached :og_image

  has_many :users
  has_many :boards
  has_many :statuses
  has_many :ideas
  has_many :comments
  has_many :votes
  has_many :invitations
  has_many :changelogs
  has_many :sessions, class_name: "Session", foreign_key: :current_account_id

  belongs_to :default_status, class_name: "Status", optional: true

  before_destroy :prepare_for_destroy, prepend: true

  validates :default_status, presence: true, on: :update

  validates :logo, content_type: { in: ALLOWED_IMAGE_CONTENT_TYPES }, file_size: { maximum: 2.megabytes }
  validates :favicon, content_type: { in: ALLOWED_IMAGE_CONTENT_TYPES }, file_size: { maximum: 500.kilobytes }
  validates :og_image, content_type: { in: ALLOWED_IMAGE_CONTENT_TYPES }, file_size: { maximum: 2.megabytes }
  validates :logo_link, url: { allow_blank: true }
  validates :name, presence: true

  # Check if user is the owner
  def owned_by?(user)
    user&.owner?
  end

  private

    def clear_default_status
      return unless has_attribute?(:default_status_id)
      return if default_status_id.nil?
      update_column(:default_status_id, nil)
    end

    def destroy_dependents_in_order
      # Ensure we don't violate foreign key constraints due to deletion order (e.g. ideas -> statuses)
      Session.where(current_account_id: id).update_all(current_account_id: nil)
      Vote.where(account_id: id).delete_all
      Comment.where(account_id: id).delete_all
      Idea.where(account_id: id).delete_all
      Invitation.where(account_id: id).delete_all
      Changelog.where(account_id: id).delete_all
      Board.where(account_id: id).delete_all
      User.where(account_id: id).delete_all
      Status.where(account_id: id).delete_all
    end

    def prepare_for_destroy
      clear_default_status
      destroy_dependents_in_order
    end
end
