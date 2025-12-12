# frozen_string_literal: true

require "test_helper"

class IdeaPolicyTest < ActiveSupport::TestCase
  setup do
    # idea two is owned by user one (who is a regular user)
    @idea = ideas(:two)
    @idea_owner = users(:one)      # regular user (owner of idea two)
    @admin_user = users(:shane)    # admin user
    @regular_user = users(:two)    # regular member user
  end

  test "idea index viewable by all" do
    assert_predicate IdeaPolicy.new(nil, @idea), :index?
  end

  test "idea show viewable by all" do
    assert_predicate IdeaPolicy.new(nil, @idea), :show?
  end

  test "idea create available by logged in users" do
    assert_not_predicate IdeaPolicy.new(nil, @idea), :create?
    assert_predicate IdeaPolicy.new(@regular_user, @idea), :create?
  end

  test "idea new available by logged in users" do
    assert_not_predicate IdeaPolicy.new(nil, @idea), :new?
    assert_predicate IdeaPolicy.new(@regular_user, @idea), :new?
  end

  test "idea edit available by idea owner or admin" do
    assert_not_predicate IdeaPolicy.new(nil, @idea), :edit?
    assert_not_predicate IdeaPolicy.new(@regular_user, @idea), :edit?
    assert_predicate IdeaPolicy.new(@idea_owner, @idea), :edit?
    assert_predicate IdeaPolicy.new(@admin_user, @idea), :edit?
  end

  test "idea update available by idea owner or admin" do
    assert_not_predicate IdeaPolicy.new(nil, @idea), :update?
    assert_not_predicate IdeaPolicy.new(@regular_user, @idea), :update?
    assert_predicate IdeaPolicy.new(@idea_owner, @idea), :update?
    assert_predicate IdeaPolicy.new(@admin_user, @idea), :update?
  end

  test "idea destroy available by idea owner or admin" do
    assert_not_predicate IdeaPolicy.new(nil, @idea), :destroy?
    assert_not_predicate IdeaPolicy.new(@regular_user, @idea), :destroy?
    assert_predicate IdeaPolicy.new(@idea_owner, @idea), :destroy?
    assert_predicate IdeaPolicy.new(@admin_user, @idea), :destroy?
  end

  test "idea pin only available to admin" do
    assert_not_predicate IdeaPolicy.new(nil, @idea), :pin?
    assert_not_predicate IdeaPolicy.new(@regular_user, @idea), :pin?
    assert_predicate IdeaPolicy.new(@admin_user, @idea), :pin?
  end

  test "idea unpin only available to admin" do
    assert_not_predicate IdeaPolicy.new(nil, @idea), :unpin?
    assert_not_predicate IdeaPolicy.new(@regular_user, @idea), :unpin?
    assert_predicate IdeaPolicy.new(@admin_user, @idea), :unpin?
  end

  test "idea update_status only available to admin" do
    assert_not_predicate IdeaPolicy.new(nil, @idea), :update_status?
    assert_not_predicate IdeaPolicy.new(@regular_user, @idea), :update_status?
    assert_not_predicate IdeaPolicy.new(@idea_owner, @idea), :update_status?
    assert_predicate IdeaPolicy.new(@admin_user, @idea), :update_status?
  end
end
