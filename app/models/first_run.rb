# frozen_string_literal: true

class FirstRun
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  # User attributes
  attribute :name, :string
  attribute :email_address, :string
  attribute :password, :string
  attribute :avatar

  # Account attributes
  attribute :account_name, :string
  attribute :account_subdomain, :string
  attribute :account_logo

  # Board attribute
  attribute :board_name, :string
  attribute :board_color, :string

  # User validations
  validates :name, presence: true
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: User::MIN_PASSWORD_LENGTH_ALLOWED }

  # Account validations
  validates :account_name, presence: true
  validates :account_subdomain, presence: true, if: -> { Rails.application.config.multi_tenant }

  # Board validations
  validates :board_name, presence: true
  validates :board_color, presence: true, format: { with: /\A#[0-9a-f]{6}\z/i }

  attr_reader :account, :user, :board

  def save!
    raise ActiveModel::ValidationError.new(self) unless valid?

    ApplicationRecord.transaction do
      Status.create!([
        { name: "Open", color: "#3b82f6", position: 1 },
        { name: "Planned", color: "#8b5cf6", position: 2 },
        { name: "In Progress", color: "#f59e0b", position: 3 },
        { name: "Complete", color: "#10b981", position: 4 },
        { name: "Closed", color: "#ef4444", position: 5 }
      ])

      @user = User.create!(user_attributes)
      @account = Account.create!(account_attributes.merge(
        default_status: Status.ordered.first
      ))
      @board = Board.create!(board_attributes)
      self
    end
  rescue ActiveRecord::RecordInvalid => e
    copy_validation_errors(e.record)
    raise ActiveModel::ValidationError.new(self)
  end

  private

    def user_attributes
      {
        name: name,
        email_address: email_address,
        password: password,
        avatar: avatar,
        role: :owner
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
