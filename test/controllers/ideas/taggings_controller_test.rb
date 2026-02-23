# frozen_string_literal: true

require "test_helper"

module Ideas
  class TaggingsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @idea = ideas(:one)
      @admin = users(:shane)
      @member = users(:jane)
    end

    test "new renders tag picker for admin" do
      sign_in_as @admin

      get new_idea_tagging_url(@idea)

      assert_response :success
    end

    test "new renders tag picker for idea creator" do
      sign_in_as @member

      get new_idea_tagging_url(ideas(:two))

      assert_response :success
    end

    test "new is forbidden for non-admin non-creator" do
      sign_in_as @member

      get new_idea_tagging_url(@idea)

      assert_response :forbidden
    end

    test "new requires authentication" do
      get new_idea_tagging_url(@idea)

      assert_redirected_to sign_in_path
    end

    test "create adds tag to idea" do
      sign_in_as @admin

      assert_difference "Tagging.count", 1 do
        post idea_taggings_url(@idea), params: { tag_title: "new-feature" }
      end

      assert @idea.reload.tags.exists?(title: "new-feature")
    end

    test "create removes tag when idea already has it" do
      sign_in_as @admin
      @idea.toggle_tag_with("removable")

      assert_difference "Tagging.count", -1 do
        post idea_taggings_url(@idea), params: { tag_title: "removable" }
      end

      assert_not @idea.reload.tags.exists?(title: "removable")
    end

    test "create redirects html request to idea" do
      sign_in_as @admin

      post idea_taggings_url(@idea), params: { tag_title: "new-feature" }

      assert_redirected_to idea_url(@idea)
    end

    test "create strips leading hash from tag title param" do
      sign_in_as @admin

      post idea_taggings_url(@idea), params: { tag_title: "#stripped" }

      assert @idea.reload.tags.exists?(title: "stripped")
    end

    test "create is forbidden for non-admin non-creator" do
      sign_in_as @member

      assert_no_difference "Tagging.count" do
        post idea_taggings_url(@idea), params: { tag_title: "unauthorized" }
      end

      assert_response :forbidden
    end

    test "create requires authentication" do
      post idea_taggings_url(@idea), params: { tag_title: "unauthenticated" }

      assert_redirected_to sign_in_path
    end

    test "destroy removes tagging" do
      sign_in_as @admin
      @idea.toggle_tag_with("to-remove")
      tagging = @idea.taggings.last

      assert_difference "Tagging.count", -1 do
        delete idea_tagging_url(@idea, tagging)
      end

      assert_not Tagging.exists?(tagging.id)
    end

    test "destroy redirects html request to idea" do
      sign_in_as @admin
      @idea.toggle_tag_with("to-remove")
      tagging = @idea.taggings.last

      delete idea_tagging_url(@idea, tagging)

      assert_redirected_to idea_url(@idea)
    end

    test "destroy is forbidden for non-admin non-creator" do
      sign_in_as @admin
      @idea.toggle_tag_with("protected")
      tagging = @idea.taggings.last

      sign_in_as @member

      assert_no_difference "Tagging.count" do
        delete idea_tagging_url(@idea, tagging)
      end

      assert_response :forbidden
    end

    test "destroy requires authentication" do
      sign_in_as @admin
      @idea.toggle_tag_with("protected")
      tagging = @idea.taggings.last
      sign_out

      delete idea_tagging_url(@idea, tagging)

      assert_redirected_to sign_in_path
    end
  end
end
