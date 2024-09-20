# frozen_string_literal: true

class User < ApplicationRecord
  USERNAME_LENGTH_LIMIT = 30

  include Transferable
  include Role
  include Mentionable

  has_many :sessions, dependent: :destroy

  has_one_attached :avatar
  has_secure_password

  validates :username, presence: true, format: {with: /\A[a-z0-9_]+\z/i}, length: {minimum: 3, maximum: USERNAME_LENGTH_LIMIT}, uniqueness: true
  validates :email_address, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :password, allow_nil: true, length: {minimum: 10}
  validates :avatar, resizable_image: true, max_file_size: 2.megabytes

  normalizes :email_address, with: -> { _1.strip.downcase }
  normalizes :username, with: ->(username) { username.squish }

  before_save :anonymize_avatar_filename

  scope :active, -> { where(active: true) }
  scope :filtered_by, ->(query) { where("name like ?", "%#{query}%") }
  scope :ordered, -> { order(:name) }

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
