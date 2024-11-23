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

  test "invalid without a author" do
    @post.author = nil

    assert_not @post.valid?
    assert_equal "must exist", @post.errors[:author].first
  end

  test "invalid without a category" do
    @post.category = nil

    assert_not @post.valid?
    assert_equal "must exist", @post.errors[:category].first
  end

  test "invalid without an organization" do
    @post.organization = nil

    assert_not @post.valid?
    assert_equal "must exist", @post.errors[:organization].first
  end
end
