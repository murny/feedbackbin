# frozen_string_literal: true

class User < ApplicationRecord
  MAX_USERNAME_LENGTH = 20
  MIN_PASSWORD_LENGTH_ALLOWED = 10
  MAX_PASSWORD_LENGTH_ALLOWED = 72 # Comes from User::BCryptPassword::MAX_PASSWORD_LENGTH_ALLOWED

  include Mentionable
  include Searchable
  include Role
  include Eventable
  include User::Activatable

  has_secure_password

  to_param :username

  scope :filtered_by, ->(query) { where("name like ?", "%#{query}%") }
  scope :ordered, -> { order(:name) }

  has_many :posts, dependent: :destroy, foreign_key: :author_id, inverse_of: :author
  has_many :sessions, dependent: :destroy
  has_many :comments, dependent: :destroy, foreign_key: :creator_id, inverse_of: :creator
  has_many :likes, dependent: :destroy, foreign_key: :voter_id, inverse_of: :voter
  has_many :user_connected_accounts, dependent: :destroy
  has_many :invitations, dependent: :destroy, foreign_key: :invited_by_id, inverse_of: :invited_by
  has_one :owned_organization, class_name: "Organization", foreign_key: :owner_id, inverse_of: :owner, dependent: :restrict_with_error

  has_one_attached :avatar

  enum :theme, { system: 0, light: 1, dark: 2 }, default: :system, prefix: true, validate: true

  validates :username, presence: true,
    length: { minimum: 3, maximum: MAX_USERNAME_LENGTH },
    uniqueness: { case_sensitive: false },
    format: {
      with: /\A[a-z0-9_]+\z/i
    }

  validates :email_address, presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password, allow_nil: true, length: { minimum: MIN_PASSWORD_LENGTH_ALLOWED }
  validates :avatar, resizable_image: true, max_file_size: 2.megabytes
  validates :bio, length: { maximum: 255 }

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
    [ name, bio ].compact_blank.join(" – ")
  end

  def organization_owner?
    owned_organization.present?
  end

  # Track events for user lifecycle (profile updates, activation changes)
  after_update_commit -> { track_event(:profile_updated) }, if: -> { saved_change_to_name? || saved_change_to_bio? }
  after_update_commit -> { track_event(:deactivated) }, if: -> { saved_change_to_active? && !active? }
  after_update_commit -> { track_event(:activated) }, if: -> { saved_change_to_active? && active? }

  private

    def anonymize_avatar_filename
      if avatar.attached?
        avatar.blob.filename = "avatar#{avatar.filename.extension_with_delimiter}"
      end
    end
end
