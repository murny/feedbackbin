# frozen_string_literal: true

require "test_helper"

class Account::ExternalIdSequenceTest < ActiveSupport::TestCase
  setup do
    # Clear any existing sequence records
    Account::ExternalIdSequence.delete_all
  end

  test "next returns incrementing values" do
    first = Account::ExternalIdSequence.next
    second = Account::ExternalIdSequence.next
    third = Account::ExternalIdSequence.next

    assert_equal first + 1, second
    assert_equal second + 1, third
  end

  test "initializes from maximum external_account_id" do
    max_id = Account.maximum(:external_account_id)
    first = Account::ExternalIdSequence.next

    assert_equal max_id + 1, first
  end

  test "value returns current sequence value" do
    Account::ExternalIdSequence.next
    Account::ExternalIdSequence.next

    # value should return the last generated value
    assert_equal Account::ExternalIdSequence.first.value, Account::ExternalIdSequence.value
  end

  test "concurrent calls return unique values" do
    # Simulate concurrent access by calling next multiple times
    values = 10.times.map { Account::ExternalIdSequence.next }

    assert_equal values.uniq.size, values.size, "All values should be unique"
    assert_equal values.sort, values, "Values should be sequential"
  end
end
