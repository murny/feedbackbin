# frozen_string_literal: true

# Provides sequential IDs for +external_account_id+ when creating accounts without one.
# Uses row-level locking to prevent race conditions during concurrent account creation.
class Account::ExternalIdSequence < ApplicationRecord
  class << self
    def next
      with_lock do |sequence|
        sequence.increment!(:value).value
      end
    end

    def value
      first&.value || self.next
    end

    private

      def with_lock
        transaction do
          sequence = lock.first_or_create!(value: initial_value)
          yield sequence
        end
      end

      def initial_value
        Account.maximum(:external_account_id) || 0
      end
  end
end
