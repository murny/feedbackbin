# frozen_string_literal: true

class User < ApplicationRecord
  include Avatar
  include Mentionable
  include Named
  include Searchable
  include Role

  belongs_to :identity
  belongs_to :account

  # Delegate authentication-related methods to identity
  delegate :email_address, to: :identity, allow_nil: true
  delegate :sessions, to: :identity, allow_nil: true
  delegate :connected_accounts, to: :identity, allow_nil: true

  # NOTE: Auth/session/token logic lives on Identity.

  scope :active, -> { where(active: true) }
  scope :deactivated, -> { where(active: false) }
  scope :filtered_by, ->(query) { where("name like ?", "%#{query}%") }
  scope :ordered, -> { alphabetically }

  has_many :ideas, dependent: :destroy, foreign_key: :author_id, inverse_of: :author
  has_many :comments, dependent: :destroy, foreign_key: :creator_id, inverse_of: :creator
  has_many :votes, dependent: :destroy, foreign_key: :voter_id, inverse_of: :voter
  has_many :invitations, dependent: :destroy, foreign_key: :invited_by_id, inverse_of: :invited_by

  enum :theme, { system: 0, light: 1, dark: 2 }, default: :system, prefix: true, validate: true

  validates :name, presence: true
  validates :identity_id, uniqueness: { scope: :account_id }
  validates :bio, length: { maximum: 255 }

  validate :account_owner_cannot_be_deactivated, if: -> { active_changed? && owner? }

  normalizes :name, with: ->(name) { name.squish }

  before_destroy :revoke_account_sessions

  def title
    [ name, bio ].compact_blank.join(" – ")
  end

  def deactivate
    success = transaction do
      if update(active: false)
        true
      else
        raise ActiveRecord::Rollback
      end
    end

    return false unless success

    revoke_account_sessions
    close_remote_connections
    true
  end

  def deactivated?
    !active?
  end

  def super_admin?
    identity.super_admin?
  end

  private

    def revoke_account_sessions
      identity&.sessions&.where(current_account: account)&.destroy_all
    end

    def close_remote_connections
      ActionCable.server.remote_connections.where(current_user: self).disconnect reconnect: false
    end

    def account_owner_cannot_be_deactivated
      errors.add(:active, :account_owner_cannot_be_deactivated)
    end
end
