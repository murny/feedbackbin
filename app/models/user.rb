# frozen_string_literal: true

class User < ApplicationRecord
  MIN_PASSWORD_LENGTH_ALLOWED = 10
  MAX_PASSWORD_LENGTH_ALLOWED = 72 # Comes from User::BCryptPassword::MAX_PASSWORD_LENGTH_ALLOWED

  include Avatar
  include Mentionable
  include Named
  include Searchable
  include Role

  has_secure_password

  scope :active, -> { where(active: true) }
  scope :deactivated, -> { where(active: false) }
  scope :filtered_by, ->(query) { where("name like ?", "%#{query}%") }
  scope :ordered, -> { alphabetically }

  has_many :ideas, dependent: :destroy, foreign_key: :author_id, inverse_of: :author
  has_many :sessions, dependent: :destroy
  has_many :comments, dependent: :destroy, foreign_key: :creator_id, inverse_of: :creator
  has_many :votes, dependent: :destroy, foreign_key: :voter_id, inverse_of: :voter
  has_many :user_connected_accounts, dependent: :destroy
  has_many :invitations, dependent: :destroy, foreign_key: :invited_by_id, inverse_of: :invited_by

  enum :theme, { system: 0, light: 1, dark: 2 }, default: :system, prefix: true, validate: true

  validates :name, presence: true

  validates :email_address, presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password, allow_nil: true, length: { minimum: MIN_PASSWORD_LENGTH_ALLOWED }
  validates :bio, length: { maximum: 255 }

  validate :account_owner_cannot_be_deactivated, if: -> { active_changed? && owner? }

  normalizes :email_address, with: ->(email) { email.strip.downcase }
  normalizes :name, with: ->(name) { name.squish }

  generates_token_for :email_verification, expires_in: 2.days do
    email_address
  end

  def title
    [ name, bio ].compact_blank.join(" – ")
  end

  def deactivate
    success = transaction do
      if update(active: false)
        sessions.delete_all
        true
      else
        raise ActiveRecord::Rollback
      end
    end

    return false unless success

    close_remote_connections
    true
  end

  def deactivated?
    !active?
  end

  private

    def close_remote_connections
      ActionCable.server.remote_connections.where(current_user: self).disconnect reconnect: false
    end

    def account_owner_cannot_be_deactivated
      errors.add(:active, :account_owner_cannot_be_deactivated)
    end
end
