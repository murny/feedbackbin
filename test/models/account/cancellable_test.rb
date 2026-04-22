# frozen_string_literal: true

require "test_helper"

class Account::CancellableTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:feedbackbin)
    @user = users(:shane)
  end

  test "cancel creates a cancellation record" do
    assert_difference -> { Account::Cancellation.count }, 1 do
      @account.cancel(initiated_by: @user)
    end

    assert @account.cancelled?
    assert_not @account.active?
    assert_equal @user, @account.cancellation.initiated_by
  end

  test "cancel is idempotent once the account is already cancelled" do
    @account.cancel(initiated_by: @user)
    original_created_at = @account.cancellation.reload.created_at

    assert_no_difference -> { Account::Cancellation.count } do
      @account.cancel(initiated_by: @user)
    end

    assert_equal original_created_at, @account.cancellation.reload.created_at
  end

  test "cancel does nothing when the app is not accepting signups" do
    Account.stubs(:accepting_signups?).returns(false)

    assert_no_difference -> { Account::Cancellation.count } do
      @account.cancel(initiated_by: @user)
    end

    assert_not @account.cancelled?
  end

  test "cancelled? returns true when cancellation exists" do
    assert_not @account.cancelled?

    @account.cancel(initiated_by: @user)

    assert @account.cancelled?
  end

  test "reactivate removes cancellation" do
    @account.cancel(initiated_by: @user)
    assert @account.cancelled?

    @account.reactivate
    @account.reload

    assert_not @account.cancelled?
    assert @account.active?
    assert_nil @account.cancellation
  end

  test "reactivate does nothing when not cancelled" do
    assert_not @account.cancelled?

    assert_nothing_raised do
      @account.reactivate
    end

    assert_not @account.cancelled?
  end
end
