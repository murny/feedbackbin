# frozen_string_literal: true

class Account::Cancellation < ApplicationRecord
  belongs_to :account
  belongs_to :initiated_by, class_name: "User"

  validate :initiated_by_belongs_to_same_account

  private

    def initiated_by_belongs_to_same_account
      return if account.blank? || initiated_by.blank?
      return if initiated_by.account_id == account_id

      errors.add(:initiated_by, "must belong to the same account")
    end
end
