# frozen_string_literal: true

require "test_helper"

class LikesControllerTest < ActionDispatch::IntegrationTest
  test "should update likeable" do
    post = posts(:one)
    user = users(:one)

    sign_in_as user

    assert_difference -> { post.likes.count }, 1 do
      patch like_url(likeable_type: "Post", likeable_id: post.id)

      assert_redirected_to post, notice: "Post was successfully liked."
    end

    assert_difference -> { post.likes.count }, -1 do
      patch like_url(likeable_type: "Post", likeable_id: post.id)

      assert_redirected_to post, notice: "Post was successfully unliked."
    end
  end

  test "should not update likeable if likeable is not an approved likeable" do
    category = categories(:one)
    user = users(:one)

    sign_in_as user

    assert_no_difference -> { Like.count } do
      patch like_url(likeable_type: "Category", likeable_id: category.id)

      assert_response :unprocessable_entity
    end
  end
end
