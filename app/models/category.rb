# frozen_string_literal: true

class Category < ApplicationRecord
  include Eventable

  # Associations
  has_many :posts, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :color, presence: true, format: { with: /\A#[0-9a-f]{6}\z/i, message: "must be a valid hex color code" }

  # Normalizations
  normalizes :name, with: ->(name) { name.squish }

  # Scopes
  scope :ordered, -> { order(arel_table[:name].lower)  }

  # Track events for category lifecycle
  after_create_commit -> { track_event(:created) }
  after_update_commit -> { track_event(:updated) }, if: -> { saved_change_to_name? || saved_change_to_description? || saved_change_to_color? }
  before_destroy -> { track_event(:deleted) }
end
