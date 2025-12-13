# frozen_string_literal: true

class FirstRun
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  # Identity attributes (authentication)
  attribute :email_address, :string
  attribute :password, :string

  # User attributes (membership)
  attribute :name, :string
  attribute :avatar

  # Account attributes
  attribute :account_name, :string
  attribute :account_subdomain, :string
  attribute :account_logo

  # Board attribute
  attribute :board_name, :string
  attribute :board_color, :string

  # Identity validations
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: Identity::MIN_PASSWORD_LENGTH_ALLOWED }

  # User validations
  validates :name, presence: true

  # Account validations
  validates :account_name, presence: true
  validates :account_subdomain, presence: true, if: -> { Rails.application.config.multi_tenant }

  # Board validations
  validates :board_name, presence: true
  validates :board_color, presence: true, format: { with: /\A#[0-9a-f]{6}\z/i }

  attr_reader :account, :identity, :user, :board

  def save!
    raise ActiveModel::ValidationError.new(self) unless valid?

    ApplicationRecord.transaction do
      # Create account first so we can associate statuses to it
      @account = Account.create!(account_attributes)

      # Create statuses for the new account
      statuses = [
        Status.new(name: "Open", color: "#3b82f6", position: 1, account: @account),
        Status.new(name: "Planned", color: "#8b5cf6", position: 2, account: @account),
        Status.new(name: "In Progress", color: "#f59e0b", position: 3, account: @account),
        Status.new(name: "Complete", color: "#10b981", position: 4, account: @account),
        Status.new(name: "Closed", color: "#ef4444", position: 5, account: @account)
      ]

      # Save all statuses
      statuses.each(&:save!)

      # Set default status now that statuses exist
      @account.update!(default_status: statuses.first)

      # Create identity (authentication)
      @identity = Identity.create!(identity_attributes)

      # Create user (membership) linking identity to account
      @user = User.create!(user_attributes.merge(
        identity: @identity,
        account: @account
      ))

      # Create board with account
      @board = Board.create!(board_attributes.merge(account: @account))

      self
    end
  rescue ActiveRecord::RecordInvalid => e
    copy_validation_errors(e.record)
    raise ActiveModel::ValidationError.new(self)
  end

  private

    def identity_attributes
      {
        email_address: email_address,
        password: password,
        super_admin: true
      }
    end

    def user_attributes
      {
        name: name,
        avatar: avatar,
        role: :owner,
        email_verified: true
      }
    end

    def account_attributes
      {
        name: account_name,
        subdomain: account_subdomain,
        logo: account_logo
      }
    end

    def board_attributes
      {
        name: board_name,
        color: board_color
      }
    end

    def copy_validation_errors(record)
      case record
      when Identity
        record.errors.each do |error|
          errors.add(error.attribute, error.message)
        end
      when User
        record.errors.each do |error|
          errors.add(error.attribute, error.message)
        end
      when Account
        attribute_mapping = {
          name: :account_name,
          subdomain: :account_subdomain,
          logo: :account_logo
        }
        record.errors.each do |error|
          attr_name = attribute_mapping[error.attribute] || error.attribute
          errors.add(attr_name, error.message)
        end
      when Board
        attribute_mapping = {
          name: :board_name,
          color: :board_color
        }
        record.errors.each do |error|
          attr_name = attribute_mapping[error.attribute] || error.attribute
          errors.add(attr_name, error.message)
        end
      end
    end
end
