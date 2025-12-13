# frozen_string_literal: true

class Identity < ApplicationRecord
  MIN_PASSWORD_LENGTH_ALLOWED = 10
  MAX_PASSWORD_LENGTH_ALLOWED = 72

  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :connected_accounts, class_name: "IdentityConnectedAccount", dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :accounts, through: :users

  validates :email_address, presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password, allow_nil: true, length: { minimum: MIN_PASSWORD_LENGTH_ALLOWED }

  normalizes :email_address, with: ->(email) { email.strip.downcase }

  attr_accessor :password_challenge
  validate :password_challenge_must_match_current_password, if: :sensitive_update?

  generates_token_for :email_verification, expires_in: 2.days do
    email_address
  end

  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt&.last(10)
  end

  def user_for(account)
    users.find_by(account: account)
  end

  def self.find_by_email_verification_token!(token)
    find_by_token_for!(:email_verification, token)
  end

  def self.find_by_password_reset_token!(token)
    find_by_token_for!(:password_reset, token)
  end

  private

    def sensitive_update?
      return false unless Current.identity == self
      will_save_change_to_email_address? || will_save_change_to_password_digest?
    end

    def password_challenge_must_match_current_password
      if password_challenge.blank?
        errors.add(:password_challenge, :blank)
        return
      end

      digest =
        if will_save_change_to_password_digest?
          password_digest_was
        else
          password_digest
        end

      ok =
        begin
          BCrypt::Password.new(digest).is_password?(password_challenge)
        rescue BCrypt::Errors::InvalidHash
          false
        end

      errors.add(:password_challenge, :invalid) unless ok
    end
end
