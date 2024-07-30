# frozen_string_literal: true

require "test_helper"

class PostTest < ActiveSupport::TestCase
  def setup
    @post = posts(:one)
  end

  test "valid post" do
    assert_predicate @post, :valid?
  end

  test "invalid without a title" do
    @post.title = nil

    assert_not @post.valid?
    assert_equal "can't be blank", @post.errors[:title].first
  end
end
