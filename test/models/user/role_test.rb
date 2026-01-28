# frozen_string_literal: true

require "test_helper"

class User::RoleTest < ActiveSupport::TestCase
  test "creating new users makes them members by default" do
    assert_predicate User.new, :member?
  end

  test "roles must be valid" do
    user = users(:jane)
    user.role = :invalid_role

    assert_not user.valid?
    assert_equal "is not included in the list", user.errors[:role].first
  end

  test "cannot change role for account owner" do
    owner = users(:shane)

    assert_not owner.update(role: :member)
    assert_equal "cannot be changed for account owner", owner.errors[:role].first
  end

  test "owner is also considered an admin" do
    assert_predicate users(:shane), :owner?
    assert_predicate users(:shane), :admin?

    assert_predicate users(:admin), :admin?
    assert_not users(:admin).owner?
  end

  test "owner scope returns only active owners" do
    owners = accounts(:feedbackbin).users.owner

    assert_includes owners, users(:shane)
    assert_not_includes owners, users(:admin)
    assert_not_includes owners, users(:jane)
  end

  test "admin scope returns active owners and admins" do
    admins = accounts(:feedbackbin).users.admin

    assert_includes admins, users(:shane)
    assert_includes admins, users(:admin)
    assert_not_includes admins, users(:jane)

    users(:admin).update!(active: false)

    assert_not_includes accounts(:feedbackbin).users.admin, users(:admin)
  end

  test "can change others?" do
    # Admin can change non-owner users
    assert users(:admin).can_change?(users(:jane))
    assert_not users(:admin).can_change?(users(:shane))

    # Users can change themselves
    assert users(:jane).can_change?(users(:jane))

    # Members cannot change other members
    assert_not users(:jane).can_change?(users(:john))
  end

  test "can administer others?" do
    assert users(:admin).can_administer?(users(:jane))

    assert_not users(:admin).can_administer?(users(:admin))
    assert_not users(:jane).can_administer?(users(:admin))
  end

  test "owner can administer admins and members" do
    assert users(:shane).can_administer?(users(:admin))
    assert users(:shane).can_administer?(users(:jane))
  end

  test "owner cannot administer themselves" do
    assert_not users(:shane).can_administer?(users(:shane))
  end

  test "admin cannot administer the owner" do
    assert_not users(:admin).can_administer?(users(:shane))
  end

  test "can administer idea?" do
    janes_idea = ideas(:two)
    shanes_idea = ideas(:one)

    # Admin can administer any idea
    assert users(:admin).can_administer_idea?(janes_idea)
    assert users(:admin).can_administer_idea?(shanes_idea)

    # Creator can administer their own idea
    assert users(:jane).can_administer_idea?(janes_idea)

    # Member cannot administer ideas they didn't create
    assert_not users(:john).can_administer_idea?(janes_idea)
    assert_not users(:john).can_administer_idea?(shanes_idea)

    # Creator cannot administer other people's ideas
    assert_not users(:jane).can_administer_idea?(shanes_idea)
  end

  test "can administer comment?" do
    janes_comment = comments(:one)
    shanes_comment = comments(:two)

    # Admin can administer any comment
    assert users(:admin).can_administer_comment?(janes_comment)
    assert users(:admin).can_administer_comment?(shanes_comment)

    # Creator can administer their own comment
    assert users(:jane).can_administer_comment?(janes_comment)

    # Member cannot administer comments they didn't create
    assert_not users(:john).can_administer_comment?(janes_comment)
    assert_not users(:john).can_administer_comment?(shanes_comment)

    # Creator cannot administer other people's comments
    assert_not users(:jane).can_administer_comment?(shanes_comment)
  end
end
