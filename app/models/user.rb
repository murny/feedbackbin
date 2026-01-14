# frozen_string_literal: true

class User < ApplicationRecord
  include Avatar, Mentionable, Named, Role, Searchable, Watcher

  scope :active, -> { where(active: true) }
  scope :deactivated, -> { where(active: false) }
  scope :filtered_by, ->(query) { where("name like ?", "%#{query}%") }
  scope :ordered, -> { alphabetically }

  belongs_to :account, default: -> { Current.account }
  belongs_to :identity, optional: true

  has_many :ideas, dependent: :destroy, foreign_key: :creator_id, inverse_of: :creator
  has_many :boards, dependent: :destroy, foreign_key: :creator_id, inverse_of: :creator
  has_many :comments, dependent: :destroy, foreign_key: :creator_id, inverse_of: :creator
  has_many :votes, dependent: :destroy, foreign_key: :voter_id, inverse_of: :voter
  has_many :invitations, dependent: :destroy, foreign_key: :invited_by_id, inverse_of: :invited_by
  has_many :notifications, dependent: :destroy

  enum :theme, { system: 0, light: 1, dark: 2 }, default: :system, prefix: true, validate: true

  validates :name, presence: true

  validates :bio, length: { maximum: 255 }

  validate :account_owner_cannot_be_deactivated, if: -> { active_changed? && owner? }

  normalizes :name, with: ->(name) { name.squish }

  def deactivate
    transaction do
      # TODO: what happens to the identity if we reactivate the user?
      update!(active: false, identity: nil)
      close_remote_connections
    end
  end

  private

    def close_remote_connections
      ActionCable.server.remote_connections.where(current_user: self).disconnect(reconnect: false)
    end

    def account_owner_cannot_be_deactivated
      errors.add(:active, :account_owner_cannot_be_deactivated)
    end
end
