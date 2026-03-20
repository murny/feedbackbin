# frozen_string_literal: true

require "test_helper"

module Admin
  class ChangelogsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:shane)
      @changelog = changelogs(:one)
      @draft = changelogs(:draft)
      sign_in_as @admin
    end

    test "should get index" do
      get admin_changelogs_url

      assert_response :success
    end

    test "index shows both draft and published entries" do
      get admin_changelogs_url

      assert_response :success
      assert_select "a", text: @changelog.title
      assert_select "a", text: @draft.title
    end

    test "should not get index if not an admin" do
      sign_in_as users(:john)

      get admin_changelogs_url

      assert_response :forbidden
    end

    test "should get new" do
      get new_admin_changelog_url

      assert_response :success
    end

    test "should not get new if not an admin" do
      sign_in_as users(:john)

      get new_admin_changelog_url

      assert_response :forbidden
    end

    test "should create changelog as draft when publish not checked" do
      assert_difference "Changelog.count", 1 do
        post admin_changelogs_url, params: { changelog: { title: "New Entry", kind: "new", description: "Some content" } }
      end

      assert_redirected_to admin_changelogs_path
      assert_equal I18n.t("admin.changelogs.create.successfully_created"), flash[:notice]
      assert_nil Changelog.last.published_at
    end

    test "should create changelog as published when publish checked" do
      assert_difference "Changelog.count", 1 do
        post admin_changelogs_url, params: { changelog: { title: "New Entry", kind: "new", description: "Some content", publish: "1" } }
      end

      assert_redirected_to admin_changelogs_path
      assert_not_nil Changelog.last.published_at
    end

    test "renders 422 on invalid create" do
      assert_no_difference "Changelog.count" do
        post admin_changelogs_url, params: { changelog: { title: "", kind: "new", description: "content" } }
      end

      assert_response :unprocessable_entity
    end

    test "non-admin cannot create" do
      sign_in_as users(:john)

      post admin_changelogs_url, params: { changelog: { title: "x", kind: "new", description: "x" } }

      assert_response :forbidden
    end

    test "should get edit" do
      get edit_admin_changelog_url(@changelog)

      assert_response :success
    end

    test "should not get edit if not an admin" do
      sign_in_as users(:john)

      get edit_admin_changelog_url(@changelog)

      assert_response :forbidden
    end

    test "should update changelog" do
      patch admin_changelog_url(@changelog), params: { changelog: { title: "Updated Title", kind: "fix", description: "Updated content", publish: "1" } }

      assert_redirected_to admin_changelogs_path
      assert_equal I18n.t("admin.changelogs.update.successfully_updated"), flash[:notice]
      assert_equal "Updated Title", @changelog.reload.title
    end

    test "updating preserves existing published_at when publish checked" do
      original_published_at = @changelog.published_at

      patch admin_changelog_url(@changelog), params: { changelog: { title: "Updated", kind: "new", description: "content", publish: "1" } }

      assert_in_delta original_published_at, @changelog.reload.published_at, 1.second
    end

    test "updating unpublishes when publish unchecked" do
      patch admin_changelog_url(@changelog), params: { changelog: { title: "Updated", kind: "new", description: "content" } }

      assert_nil @changelog.reload.published_at
    end

    test "renders 422 on invalid update" do
      patch admin_changelog_url(@changelog), params: { changelog: { title: "", kind: "new", description: "content" } }

      assert_response :unprocessable_entity
    end

    test "non-admin cannot update" do
      sign_in_as users(:john)

      patch admin_changelog_url(@changelog), params: { changelog: { title: "x", kind: "fix", description: "x" } }

      assert_response :forbidden
    end

    test "should destroy changelog" do
      assert_difference "Changelog.count", -1 do
        delete admin_changelog_url(@changelog)
      end

      assert_redirected_to admin_changelogs_path
      assert_equal I18n.t("admin.changelogs.destroy.successfully_destroyed"), flash[:notice]
    end

    test "non-admin cannot destroy" do
      sign_in_as users(:john)

      delete admin_changelog_url(@changelog)

      assert_response :forbidden
    end
  end
end
