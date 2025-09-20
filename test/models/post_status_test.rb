# frozen_string_literal: true

require "test_helper"

class PostStatusTest < ActiveSupport::TestCase
  def setup
    @post_status = post_statuses(:complete)
  end

  test "valid post_status" do
    assert_predicate @post_status, :valid?
  end

  test "invalid without name" do
    @post_status.name = nil

    assert_not @post_status.valid?
    assert_equal "can't be blank", @post_status.errors[:name].first
  end

  test "invalid without position" do
    @post_status.position = nil

    assert_not @post_status.valid?
    assert_equal "can't be blank", @post_status.errors[:position].first
  end

  test "invalid if position is not an integer" do
    @post_status.position = 1.5

    assert_not @post_status.valid?
    assert_equal "must be an integer", @post_status.errors[:position].first
  end

  test "invalid without color" do
    @post_status.color = nil

    assert_not @post_status.valid?
    assert_equal "can't be blank", @post_status.errors[:color].first
  end

  test "invalid if color is not in the correct format" do
    @post_status.color = "red"

    assert_not @post_status.valid?
    assert_equal "is invalid", @post_status.errors[:color].first
  end

  test "dependent nullify on posts" do
    post = posts(:one)
    post.post_status = @post_status
    @post_status.destroy

    assert_nil post.reload.post_status
  end
end
