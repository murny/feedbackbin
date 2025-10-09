# frozen_string_literal: true

class PostStatus < ApplicationRecord
  has_many :posts, dependent: :restrict_with_error

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  validates :color, presence: true, format: { with: /\A#[0-9a-f]{6}\z/i }

  scope :ordered, -> { order(:position) }
  scope :default, -> { Current.organization&.default_post_status }

  before_destroy :prevent_default_deletion

  private

    def prevent_default_deletion
      if self == PostStatus.default
        errors.add(:base, :cannot_delete_default)
        throw(:abort)
      end
    end
end
