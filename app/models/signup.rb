# frozen_string_literal: true

class Signup
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
  attribute :account_logo

  validates :name, presence: true
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: Identity::MIN_PASSWORD_LENGTH, maximum: Identity::MAX_PASSWORD_LENGTH }
  validates :account_name, presence: true

  attr_reader :account, :user, :identity

  def save!
    raise ActiveModel::ValidationError.new(self) unless valid?

    ApplicationRecord.transaction do
      @identity = Identity.create!(email_address: email_address, password: password, email_verified_at: Time.current)

      @account = Account.create_with_owner(
        account: {
          name: account_name,
          logo: account_logo
        },
        owner: {
          name: name,
          avatar: avatar,
          identity: @identity
        }
      )
      @user = @account.users.find_by!(role: :owner)
    end

    # Setup template data outside the transaction so after_create_commit
    # callbacks (which run after transaction commit) have Current.user set
    @account.setup_template

    self
  rescue ActiveRecord::RecordInvalid => e
    copy_validation_errors(e.record)
    raise ActiveModel::ValidationError.new(self)
  end

  private

    def copy_validation_errors(record)
      case record
      when Identity
        attribute_mapping = {
          email_address: :email_address,
          password: :password
        }
        record.errors.each do |error|
          attr_name = attribute_mapping[error.attribute] || error.attribute
          errors.add(attr_name, error.message)
        end
      when User
        record.errors.each do |error|
          errors.add(error.attribute, error.message)
        end
      when Account
        attribute_mapping = {
          name: :account_name,
          logo: :account_logo
        }
        record.errors.each do |error|
          attr_name = attribute_mapping[error.attribute] || error.attribute
          errors.add(attr_name, error.message)
        end
      end
    end
end
