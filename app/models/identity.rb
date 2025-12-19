# frozen_string_literal: true

class Identity < ApplicationRecord
  MIN_PASSWORD_LENGTH_ALLOWED = 10
  MAX_PASSWORD_LENGTH_ALLOWED = 72 # Comes from User::BCryptPassword::MAX_PASSWORD_LENGTH_ALLOWED

  include Joinable, Transferable

  # has_many :access_tokens, dependent: :destroy
  # has_many :magic_links, dependent: :destroy
  #
  has_many :identity_connected_accounts, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :users, dependent: :nullify
  has_many :accounts, through: :users

  before_destroy :deactivate_users, prepend: true

  has_secure_password validations: false, reset_token: { expires_in: 20.minutes }

  attr_accessor :password_challenge

  validates :password,
            presence: true,
            confirmation: true,
            length: { minimum: MIN_PASSWORD_LENGTH_ALLOWED, maximum: MAX_PASSWORD_LENGTH_ALLOWED },
            if: -> { password.present? || password_digest_changed? }

  validate :password_challenge_is_valid, if: -> { password_challenge.present? }

  validates :email_address, presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email_address, with: ->(value) { value.strip.downcase.presence }

  generates_token_for :email_verification, expires_in: 2.days do
    email_address
  end


  # def self.find_by_permissable_access_token(token, method:)
  #   if (access_token = AccessToken.find_by(token: token)) && access_token.allows?(method)
  #     access_token.identity
  #   end
  # end

  # def send_magic_link(**attributes)
  #   attributes[:purpose] = attributes.delete(:for) if attributes.key?(:for)

  #   magic_links.create!(attributes).tap do |magic_link|
  #     MagicLinkMailer.sign_in_instructions(magic_link).deliver_later
  #   end
  # end

  private
    def deactivate_users
      users.find_each(&:deactivate)
    end

    def password_challenge_is_valid
      original_digest = password_digest_was || password_digest
      errors.add(:password_challenge, :invalid) unless BCrypt::Password.new(original_digest).is_password?(password_challenge)
    end
end
