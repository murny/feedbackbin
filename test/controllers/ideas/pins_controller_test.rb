# frozen_string_literal: true

require "test_helper"

module Ideas
  class PinsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @idea = ideas(:one)
      @admin_user = users(:shane)
    end

    test "should pin idea when user is admin" do
      sign_in_as(@admin_user)

      assert_not @idea.pinned?

      post idea_pin_path(@idea)

      assert_response :redirect
      assert_redirected_to @idea
      assert_predicate @idea.reload, :pinned?
      assert_match "Idea has been pinned", flash[:notice]
    end

    test "should unpin idea when user is admin" do
      sign_in_as(@admin_user)
      @idea.update!(pinned: true)

      assert_predicate @idea, :pinned?

      delete idea_pin_path(@idea)

      assert_response :redirect
      assert_redirected_to @idea
      assert_not @idea.reload.pinned?
      assert_match "Idea has been unpinned", flash[:notice]
    end

    test "should redirect unauthenticated user trying to pin idea" do
      post idea_pin_path(@idea)

      assert_response :redirect
      assert_not @idea.reload.pinned?
    end

    test "should redirect unauthenticated user trying to unpin idea" do
      @idea.update!(pinned: true)

      delete idea_pin_path(@idea)

      assert_response :redirect
      assert_predicate @idea.reload, :pinned?
    end

    test "should pin idea via turbo stream" do
      sign_in_as(@admin_user)

      assert_not @idea.pinned?

      post idea_pin_path(@idea), as: :turbo_stream

      assert_response :success
      assert_equal "text/vnd.turbo-stream.html", @response.media_type
      assert_predicate @idea.reload, :pinned?

      # Verify turbo stream updates both the button and badge
      assert_match "turbo-stream", @response.body
      assert_match "idea-pin-button", @response.body
      assert_match "idea-pinned-badge", @response.body
    end

    test "should unpin idea via turbo stream" do
      sign_in_as(@admin_user)
      @idea.update!(pinned: true)

      assert_predicate @idea, :pinned?

      delete idea_pin_path(@idea), as: :turbo_stream

      assert_response :success
      assert_equal "text/vnd.turbo-stream.html", @response.media_type
      assert_not @idea.reload.pinned?

      # Verify turbo stream updates both the button and badge
      assert_match "turbo-stream", @response.body
      assert_match "idea-pin-button", @response.body
      assert_match "idea-pinned-badge", @response.body
    end
  end
end
