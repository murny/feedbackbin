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
  validate :tenant_consistency

  # Scopes
  scope :ordered_by_recently_accessed, -> { order(accessed_at: :desc) }

  private

    def tenant_consistency
      return unless board && user
      return if board.account_id == user.account_id && (account_id.nil? || account_id == board.account_id)

      errors.add(:base, :tenant_mismatch)
    end
end
