# frozen_string_literal: true

require "test_helper"

class AccessTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    @access = accesses(:shane_feature_requests)
  end

  test "valid access" do
    assert_predicate @access, :valid?
  end

  # Associations
  test "belongs to account" do
    assert_equal accounts(:feedbackbin), @access.account
  end

  test "belongs to board" do
    assert_equal boards(:one), @access.board
  end

  test "belongs to user" do
    assert_equal users(:shane), @access.user
  end

  # Enum
  test "involvement defaults to access_only" do
    access = Access.new(board: boards(:two), user: users(:jane), account: accounts(:feedbackbin))

    assert_predicate access, :involvement_access_only?
  end

  test "involvement can be watching" do
    assert_predicate @access, :involvement_watching?
  end

  test "invalid with unknown involvement" do
    @access.involvement = :invalid

    assert_not @access.valid?
    assert_includes @access.errors[:involvement], "is not included in the list"
  end

  # Tenant consistency
  test "invalid when user belongs to different account than board" do
    cross_tenant = Access.new(
      account: accounts(:feedbackbin),
      board: boards(:one),
      user: users(:acme_admin)
    )

    assert_not cross_tenant.valid?
    assert_includes cross_tenant.errors[:base], "account, board, and user must belong to the same account"
  end

  # Uniqueness
  test "invalid with duplicate board and user" do
    duplicate = Access.new(
      account: @access.account,
      board: @access.board,
      user: @access.user,
      involvement: :access_only
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  # Scopes
  test "ordered_by_recently_accessed returns most recent first" do
    recent = accesses(:shane_feature_requests)
    older = accesses(:shane_bug_reports)

    ordered = Access.ordered_by_recently_accessed

    assert_operator ordered.index(recent), :<, ordered.index(older)
  end
end
