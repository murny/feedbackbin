# frozen_string_literal: true

require "test_helper"

class PostPolicyTest < ActiveSupport::TestCase
  setup do
    # post two is owned by user one (who is a regular user)
    @post = posts(:two)
    @post_owner = users(:one)      # regular user (owner of post two)
    @admin_user = users(:shane)    # admin user
    @regular_user = users(:two)    # regular member user
  end

  test "post index viewable by all" do
    assert_predicate PostPolicy.new(nil, @post), :index?
  end

  test "post show viewable by all" do
    assert_predicate PostPolicy.new(nil, @post), :show?
  end

  test "post create available by logged in users" do
    assert_not_predicate PostPolicy.new(nil, @post), :create?
    assert_predicate PostPolicy.new(@regular_user, @post), :create?
  end

  test "post new available by logged in users" do
    assert_not_predicate PostPolicy.new(nil, @post), :new?
    assert_predicate PostPolicy.new(@regular_user, @post), :new?
  end

  test "post edit available by post owner or admin" do
    assert_not_predicate PostPolicy.new(nil, @post), :edit?
    assert_not_predicate PostPolicy.new(@regular_user, @post), :edit?
    assert_predicate PostPolicy.new(@post_owner, @post), :edit?
    assert_predicate PostPolicy.new(@admin_user, @post), :edit?
  end

  test "post update available by post owner or admin" do
    assert_not_predicate PostPolicy.new(nil, @post), :update?
    assert_not_predicate PostPolicy.new(@regular_user, @post), :update?
    assert_predicate PostPolicy.new(@post_owner, @post), :update?
    assert_predicate PostPolicy.new(@admin_user, @post), :update?
  end

  test "post destroy available by post owner or admin" do
    assert_not_predicate PostPolicy.new(nil, @post), :destroy?
    assert_not_predicate PostPolicy.new(@regular_user, @post), :destroy?
    assert_predicate PostPolicy.new(@post_owner, @post), :destroy?
    assert_predicate PostPolicy.new(@admin_user, @post), :destroy?
  end

  test "post pin only available to admin" do
    assert_not_predicate PostPolicy.new(nil, @post), :pin?
    assert_not_predicate PostPolicy.new(@regular_user, @post), :pin?
    assert_predicate PostPolicy.new(@admin_user, @post), :pin?
  end

  test "post unpin only available to admin" do
    assert_not_predicate PostPolicy.new(nil, @post), :unpin?
    assert_not_predicate PostPolicy.new(@regular_user, @post), :unpin?
    assert_predicate PostPolicy.new(@admin_user, @post), :unpin?
  end

  test "post update_status only available to admin" do
    assert_not_predicate PostPolicy.new(nil, @post), :update_status?
    assert_not_predicate PostPolicy.new(@regular_user, @post), :update_status?
    assert_not_predicate PostPolicy.new(@post_owner, @post), :update_status?
    assert_predicate PostPolicy.new(@admin_user, @post), :update_status?
  end
end
