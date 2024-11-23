# frozen_string_literal: true

class User < ApplicationRecord
  MAX_USERNAME_LENGTH = 20

  include Mentionable

  has_secure_password

  scope :active, -> { where(active: true) }
  scope :filtered_by, ->(query) { where("name like ?", "%#{query}%") }
  scope :ordered, -> { order(:name) }

  has_many :organization_invitations, dependent: :nullify, foreign_key: :invited_by_id, inverse_of: :invited_by
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :owned_organizations, class_name: "Organization", foreign_key: :owner_id, inverse_of: :owner, dependent: :destroy
  has_many :posts, dependent: :destroy, foreign_key: :author_id, inverse_of: :author
  has_many :sessions, dependent: :destroy
  has_many :comments, dependent: :destroy, foreign_key: :creator_id, inverse_of: :creator
  has_many :likes, dependent: :destroy, foreign_key: :voter_id, inverse_of: :voter
  has_many :user_connected_accounts, dependent: :destroy

  has_one_attached :avatar

  enum :theme, {system: 0, light: 1, dark: 2}, default: :system, prefix: true, validate: true

  validates :username, presence: true,
    length: {minimum: 3, maximum: MAX_USERNAME_LENGTH},
    uniqueness: {case_sensitive: false},
    format: {
      with: /\A[a-z0-9_]+\z/i
    }

  validates :email_address, presence: true,
    uniqueness: {case_sensitive: false},
    format: {with: URI::MailTo::EMAIL_REGEXP}

  validates :password, allow_nil: true, length: {minimum: 10}
  validates :avatar, resizable_image: true, max_file_size: 2.megabytes
  validates :bio, length: {maximum: 255}

  normalizes :email_address, with: ->(email) { email.strip.downcase }
  normalizes :username, with: ->(username) { username.squish }
  normalizes :name, with: ->(name) { name.squish }

  before_save :anonymize_avatar_filename

  generates_token_for :email_verification, expires_in: 2.days do
    email_address
  end

  def initials
    name.scan(/\b\w/).join
  end

  def title
    [name, bio].compact_blank.join(" – ")
  end

  def deactivate
    transaction do
      close_remote_connections

      sessions.delete_all

      update! active: false, email_address: deactived_email_address
    end
  end

  def deactivated?
    !active?
  end

  private

  def deactived_email_address
    email_address.gsub(/@/, "-deactivated-#{SecureRandom.uuid}@")
  end

  def close_remote_connections
    ActionCable.server.remote_connections.where(current_user: self).disconnect reconnect: false
  end

  def anonymize_avatar_filename
    if avatar.attached?
      avatar.blob.filename = "avatar#{avatar.filename.extension_with_delimiter}"
    end
  end
end
