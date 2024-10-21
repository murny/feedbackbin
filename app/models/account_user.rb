# frozen_string_literal: true

class AccountUser < ApplicationRecord
  include Role

  belongs_to :account, counter_cache: true
  belongs_to :user

  validates :user, uniqueness: {scope: :account_id}
  validate :owner_must_be_administrator, on: :update, if: -> { role_changed? && account_owner? }

  def account_owner?
    account.owner_id == user_id
  end

  private

  def owner_must_be_administrator
    errors.add :role, :administrator_cannot_be_removed unless administrator?
  end
end
