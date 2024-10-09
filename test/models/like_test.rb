# frozen_string_literal: true

require "test_helper"

class LikeTest < ActiveSupport::TestCase
  def setup
    @like = likes(:one)
  end

  test "valid like" do
    assert_predicate @like, :valid?
  end

  test "invalid without voter" do
    @like.voter = nil

    assert_not @like.valid?
    assert_equal "must exist", @like.errors[:voter].first
  end

  test "invalid without likeable" do
    @like.likeable = nil

    assert_not @like.valid?
    assert_equal "must exist", @like.errors[:likeable].first
  end
end
