# frozen_string_literal: true

class Access < ApplicationRecord
  # Associations
  belongs_to :account, default: -> { Current.account }
  belongs_to :board
  belongs_to :user

  # Enums
  enum :involvement, { access_only: 0, watching: 1 }, default: :access_only, prefix: true, validate: true

  # Validations
  validates :user_id, uniqueness: { scope: :board_id }

  # Scopes
  scope :ordered_by_recently_accessed, -> { order(accessed_at: :desc) }
end
