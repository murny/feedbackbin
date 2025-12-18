# frozen_string_literal: true

class Board < ApplicationRecord
  # Associations
  belongs_to :account, default: -> { Current.account }
  belongs_to :creator, class_name: "User", default: -> { Current.user }
  has_many :ideas, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true, uniqueness: { scope: :account_id, case_sensitive: false }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :color, presence: true, format: { with: /\A#[0-9a-f]{6}\z/i, message: "must be a valid hex color code" }

  # Normalizations
  normalizes :name, with: ->(name) { name.squish }

  # Scopes
  scope :ordered, -> { order(arel_table[:name].lower)  }
end
