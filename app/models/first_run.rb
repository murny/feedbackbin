# frozen_string_literal: true

class FirstRun
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  DEFAULT_CATEGORY_NAME = "Feature Requests"

  # User attributes
  attribute :username, :string
  attribute :name, :string
  attribute :email_address, :string
  attribute :password, :string
  attribute :avatar

  # Organization attributes
  attribute :organization_name, :string
  attribute :organization_subdomain, :string
  attribute :organization_logo

  # Category attribute
  attribute :category_name, :string, default: DEFAULT_CATEGORY_NAME

  # User validations
  validates :username, presence: true, length: { maximum: User::MAX_USERNAME_LENGTH }
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: User::MIN_PASSWORD_LENGTH_ALLOWED }

  # Organization validations
  validates :organization_name, presence: true
  validates :organization_subdomain, presence: true

  # Category validations
  validates :category_name, presence: true

  attr_reader :organization, :user

  # Class-level create! method for convenience
  def self.create!(attributes = {})
    new(attributes).save!
  end

  def save!
    raise ActiveRecord::RecordInvalid.new(self) unless valid?

    ApplicationRecord.transaction do
      @user = User.create!(user_attributes)
      @organization = Organization.create!(organization_attributes(@user))
      self
    end
  rescue ActiveRecord::RecordInvalid => e
    copy_validation_errors(e.record)
    raise ActiveRecord::RecordInvalid.new(self)
  end

  private

    def user_attributes
      {
        username: username,
        name: name,
        email_address: email_address,
        password: password,
        avatar: avatar
      }
    end

    def organization_attributes(user)
      {
        name: organization_name,
        subdomain: organization_subdomain,
        logo: organization_logo,
        owner: user,
        categories_attributes: [ { name: category_name } ]
      }
    end

    def copy_validation_errors(record)
      attribute_mapping = record.is_a?(Organization) ? { name: :organization_name, subdomain: :organization_subdomain } : {}

      record.errors.each do |error|
        attr_name = attribute_mapping[error.attribute] || error.attribute
        errors.add(attr_name, error.message)
      end
    end
end
