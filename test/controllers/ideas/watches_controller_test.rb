# frozen_string_literal: true

require "test_helper"

module Ideas
  class WatchesControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as(users(:shane))
      @idea = ideas(:one)
    end

    test "should show watch state" do
      get idea_watch_url(@idea)

      assert_response :success
    end

    test "should create watch" do
      idea = ideas(:two)
      idea.unwatch_by(users(:shane)) if idea.watched_by?(users(:shane))

      post idea_watch_url(idea)

      assert idea.reload.watched_by?(users(:shane))
      assert_response :redirect
    end

    test "should create watch with turbo stream" do
      idea = ideas(:two)

      post idea_watch_url(idea), as: :turbo_stream

      assert_response :success
      assert idea.reload.watched_by?(users(:shane))
    end

    test "should destroy watch" do
      assert_changes -> { @idea.watched_by?(users(:shane)) }, from: true, to: false do
        delete idea_watch_url(@idea)
        @idea.reload
      end

      assert_response :redirect
    end

    test "should destroy watch with turbo stream" do
      delete idea_watch_url(@idea), as: :turbo_stream

      assert_response :success
      assert_not @idea.reload.watched_by?(users(:shane))
    end

    test "should require authentication" do
      sign_out

      post idea_watch_url(@idea)

      assert_redirected_to sign_in_path
    end
  end
end
