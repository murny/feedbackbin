# frozen_string_literal: true

require "test_helper"

module Posts
  class StatusesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @post = posts(:one)
      @admin_user = users(:shane)
      @planned_status = post_statuses(:planned)
      @open_status = post_statuses(:open)
    end

    test "should update post status when user is admin" do
      sign_in_as(@admin_user)

      assert_equal @open_status, @post.post_status

      patch post_status_path(@post), params: { post_status_id: @planned_status.id }

      assert_response :redirect
      assert_redirected_to @post
      assert_equal @planned_status, @post.reload.post_status
    end

    test "should deny unauthenticated user from updating status" do
      patch post_status_path(@post), params: { post_status_id: @planned_status.id }

      assert_response :redirect
      assert_equal @open_status, @post.reload.post_status
    end

    test "should deny non-admin user from updating status" do
      non_admin = users(:one)
      sign_in_as(non_admin)

      patch post_status_path(@post), params: { post_status_id: @planned_status.id }

      assert_response :redirect
      assert_equal @open_status, @post.reload.post_status
    end
  end
end
