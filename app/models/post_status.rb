# frozen_string_literal: true

class PostStatus < ApplicationRecord
  include Broadcastable

  has_many :posts, dependent: :restrict_with_error

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  validates :color, presence: true, format: { with: /\A#[0-9a-f]{6}\z/i }

  # Visibility flag validations
  validates :show_on_feedback, inclusion: { in: [ true, false ] }
  validates :show_on_roadmap, inclusion: { in: [ true, false ] }

  scope :ordered, -> { order(:position) }

  # Visibility scopes
  scope :visible_on_feedback, -> { where(show_on_feedback: true) }
  scope :visible_on_roadmap, -> { where(show_on_roadmap: true) }

  # Class method to get the default post status for the current organization
  def self.default
    Current.organization&.default_post_status
  end

  before_destroy :prevent_default_deletion

  # Broadcast to all posts when status changes
  def broadcast_targets
    [:post_statuses]
  end

  private

    def prevent_default_deletion
      if self == PostStatus.default
        errors.add(:base, :cannot_delete_default)
        throw(:abort)
      end
    end
end
