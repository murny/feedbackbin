# frozen_string_literal: true

require "test_helper"

class StatusTest < ActiveSupport::TestCase
  def setup
    @status = statuses(:complete)
  end

  test "valid status" do
    assert_predicate @status, :valid?
  end

  test "invalid without name" do
    @status.name = nil

    assert_not @status.valid?
    assert_equal "can't be blank", @status.errors[:name].first
  end

  test "invalid without position" do
    @status.position = nil

    assert_not @status.valid?
    assert_equal "can't be blank", @status.errors[:position].first
  end

  test "invalid if position is not an integer" do
    @status.position = 1.5

    assert_not @status.valid?
    assert_equal "must be an integer", @status.errors[:position].first
  end

  test "invalid without color" do
    @status.color = nil

    assert_not @status.valid?
    assert_equal "can't be blank", @status.errors[:color].first
  end

  test "invalid if color is not in the correct format" do
    @status.color = "red"

    assert_not @status.valid?
    assert_equal "is invalid", @status.errors[:color].first
  end

  test "dependent nullify on posts" do
    post = posts(:one)
    post.status = @status
    @status.destroy

    assert_nil post.reload.status
  end
end
