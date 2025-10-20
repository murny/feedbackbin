# frozen_string_literal: true

class PostStatus < ApplicationRecord
  has_many :posts, dependent: :restrict_with_error

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  validates :color, presence: true, format: { with: /\A#[0-9a-f]{6}\z/i }

  # Visibility flag validations
  validates :show_on_feedback, inclusion: { in: [ true, false ] }
  validates :show_on_roadmap, inclusion: { in: [ true, false ] }

  scope :ordered, -> { order(:position) }
  scope :default, -> { Current.organization&.default_post_status }

  # Visibility scopes
  scope :visible_on_feedback, -> { where(show_on_feedback: true) }
  scope :visible_on_roadmap, -> { where(show_on_roadmap: true) }

  before_destroy :prevent_default_deletion

  private

    def prevent_default_deletion
      if self == PostStatus.default
        errors.add(:base, :cannot_delete_default)
        throw(:abort)
      end
    end
end
