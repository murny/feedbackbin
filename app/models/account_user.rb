class AccountUser < ApplicationRecord
  include UpdatesSubscriptionQuantity
  include Roles

  belongs_to :account, counter_cache: true
  belongs_to :user

  validates :user_id, uniqueness: {scope: :account_id}
  validate :owner_must_be_admin, on: :update, if: -> { admin_changed? && account_owner? }

  # Updates the subscription quantity automatically when charge_per_unit is enabled
  updates_subscription_quantity -> { account.per_unit_quantity }

  def account_owner?
    account.owner_id == user_id
  end

  def owner_must_be_admin
    errors.add :admin, :cannot_be_removed unless admin?
  end
end
