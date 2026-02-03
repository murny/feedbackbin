# frozen_string_literal: true

require "test_helper"

class ReactionTest < ActiveSupport::TestCase
  setup do
    @comment = comments(:one)
    @user = users(:shane)
  end

  test "valid reaction" do
    reaction = Reaction.new(
      reactable: @comment,
      reacter: @user,
      content: "👍"
    )

    assert_predicate reaction, :valid?
  end

  test "requires content" do
    reaction = Reaction.new(
      reactable: @comment,
      reacter: @user,
      content: ""
    )

    assert_not reaction.valid?
    assert_includes reaction.errors[:content], "can't be blank"
  end

  test "content max length is 16" do
    reaction = Reaction.new(
      reactable: @comment,
      reacter: @user,
      content: "a" * 17
    )

    assert_not reaction.valid?
    assert_includes reaction.errors[:content], "is too long (maximum is 16 characters)"
  end

  test "user cannot react with same emoji twice on same comment" do
    Reaction.create!(
      reactable: @comment,
      reacter: @user,
      content: "👍"
    )

    duplicate = Reaction.new(
      reactable: @comment,
      reacter: @user,
      content: "👍"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:reacter_id], "you have already reacted with this emoji"
  end

  test "user can react with different emojis on same comment" do
    Reaction.create!(
      reactable: @comment,
      reacter: @user,
      content: "👍"
    )

    different_emoji = Reaction.new(
      reactable: @comment,
      reacter: @user,
      content: "❤️"
    )

    assert_predicate different_emoji, :valid?
  end

  test "different users can react with same emoji" do
    Reaction.create!(
      reactable: @comment,
      reacter: @user,
      content: "👍"
    )

    other_user = users(:john)
    other_reaction = Reaction.new(
      reactable: @comment,
      reacter: other_user,
      content: "👍"
    )

    assert_predicate other_reaction, :valid?
  end

  test "defaults account from reactable" do
    reaction = Reaction.create!(
      reactable: @comment,
      reacter: @user,
      content: "👍"
    )

    assert_equal @comment.account, reaction.account
  end

  test "defaults reacter from Current.user" do
    Current.user = @user
    reaction = Reaction.create!(
      reactable: @comment,
      content: "👍"
    )

    assert_equal @user, reaction.reacter
  ensure
    Current.user = nil
  end
end
