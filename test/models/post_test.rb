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
    # Stub the default current user to nil so we can test the validation
    Current.stub(:user, nil) do
      @post.author = nil

      assert_not @post.valid?
      assert_equal "must exist", @post.errors[:author].first
    end
  end

  test "invalid without a category" do
    @post.category = nil

    assert_not @post.valid?
    assert_equal "must exist", @post.errors[:category].first
  end

  test "invalid without a post_status" do
    # Stub the default status to nil so we can test the validation
    PostStatus.stub(:default, nil) do
      @post.post_status = nil

      assert_not @post.valid?
      assert_equal "must exist", @post.errors[:post_status].first
    end
  end

  test "new post gets default status automatically" do
    post = Post.create(
      title: "Test",
      author: users(:shane),
      category: categories(:one)
    )

    # Default should be set automatically from organization's default
    assert_not_nil post.post_status
    assert_equal PostStatus.default, post.post_status
    assert_equal "Open", post.post_status.name
  end
end
