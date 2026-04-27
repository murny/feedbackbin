# frozen_string_literal: true

class Board < ApplicationRecord
  # Associations
  belongs_to :account, default: -> { Current.account }
  belongs_to :creator, class_name: "User", default: -> { Current.user }
  has_many :accesses, dependent: :destroy
  has_many :users, through: :accesses
  has_many :ideas, dependent: :restrict_with_error
  has_many :events, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: { scope: :account_id, case_sensitive: false }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :color, presence: true, format: { with: /\A#[0-9a-f]{6}\z/i, message: "must be a valid hex color code" }

  # Normalizations
  normalizes :name, with: ->(name) { name.squish }

  # Scopes
  scope :ordered, -> { order(arel_table[:name].lower)  }
  scope :all_access, -> { where(all_access: true) }

  # Callbacks
  after_create :grant_creator_access

  def access_for(user)
    accesses.find_by(user: user)
  end

  def accessible_to?(user)
    all_access? || accesses.exists?(user: user)
  end

  def accessed_by(user)
    return unless accessible_to?(user)

    access = accesses.find_or_create_by!(user: user, account: account)
    access.touch(:accessed_at)
    access
  end

  private

    def grant_creator_access
      accesses.create!(user: creator, account: account, involvement: :watching)
    end
end
