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
  validates :username, presence: true,
            length: { minimum: 3, maximum: User::MAX_USERNAME_LENGTH },
            format: { with: /\A[a-z0-9_]+\z/i }
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: User::MIN_PASSWORD_LENGTH_ALLOWED }

  # Organization validations
  validates :organization_name, presence: true
  validates :organization_subdomain, presence: true

  # Category validations
  validates :category_name, presence: true

  attr_reader :organization, :user, :category

  def save!
    raise ActiveModel::ValidationError.new(self) unless valid?

    ApplicationRecord.transaction do
      PostStatus.create!([
        { name: "Open", color: "#3b82f6", position: 1 },
        { name: "Planned", color: "#8b5cf6", position: 2 },
        { name: "In Progress", color: "#f59e0b", position: 3 },
        { name: "Complete", color: "#10b981", position: 4 },
        { name: "Closed", color: "#ef4444", position: 5 }
      ])

      @user = User.create!(user_attributes)
      @organization = Organization.create!(organization_attributes.merge(default_post_status: PostStatus.ordered.first))
      @category = Category.create!(category_attributes)
      self
    end
  rescue ActiveRecord::RecordInvalid => e
    copy_validation_errors(e.record)
    raise ActiveModel::ValidationError.new(self)
  end

  private

    def user_attributes
      {
        username: username,
        name: name,
        email_address: email_address,
        password: password,
        avatar: avatar,
        role: :administrator
      }
    end

    def organization_attributes
      {
        name: organization_name,
        subdomain: organization_subdomain,
        logo: organization_logo
      }
    end

    def category_attributes
      {
        name: category_name
      }
    end

    def copy_validation_errors(record)
      case record
      when User
        record.errors.each do |error|
          errors.add(error.attribute, error.message)
        end
      when Organization
        attribute_mapping = {
          name: :organization_name,
          subdomain: :organization_subdomain,
          logo: :organization_logo
        }
        record.errors.each do |error|
          attr_name = attribute_mapping[error.attribute] || error.attribute
          errors.add(attr_name, error.message)
        end
      when Category
        attribute_mapping = {
          name: :category_name
        }
        record.errors.each do |error|
          attr_name = attribute_mapping[error.attribute] || error.attribute
          errors.add(attr_name, error.message)
        end
      end
    end
end
