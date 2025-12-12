# frozen_string_literal: true

require "test_helper"

module Admin
  class IdeasControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:shane)
      @idea = ideas(:one)
      sign_in_as @admin
    end

    test "should get index" do
      get admin_ideas_path

      assert_response :success
      assert_includes @response.body, "Idea"
    end

    test "should get index with search" do
      get admin_ideas_path, params: { search: "dark" }

      assert_response :success
      assert_includes @response.body, "dark"
    end

    test "should get index as turbo_stream" do
      get admin_ideas_path, as: :turbo_stream

      assert_response :success
      assert_equal "text/vnd.turbo-stream.html", @response.media_type
    end

    test "should show idea" do
      get admin_idea_path(@idea)

      assert_response :success
      assert_includes @response.body, @idea.title
    end

    test "should require authentication" do
      sign_out
      get admin_ideas_path

      assert_redirected_to sign_in_path
    end
  end
end
