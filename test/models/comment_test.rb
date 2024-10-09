# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  setup do
    @comment = comments(:one)
  end

  test "valid comment" do
    assert_predicate @comment, :valid?
  end

  test "invalid without body" do
    @comment.body = nil

    assert_not @comment.valid?
    assert_equal "can't be blank", @comment.errors[:body].first
  end
end
