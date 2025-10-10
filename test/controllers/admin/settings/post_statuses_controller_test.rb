# frozen_string_literal: true

require "test_helper"

module Admin
  module Settings
    class PostStatusesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:shane)
        @post_status = post_statuses(:open)
        @organization = organizations(:feedbackbin)
        sign_in_as @admin
      end

      test "should get index" do
        get admin_settings_post_statuses_url

        assert_response :success
      end

      test "should not get index if not an admin" do
        sign_in_as users(:two)

        get admin_settings_post_statuses_url

        assert_response :redirect
        assert_equal I18n.t("unauthorized"), flash[:alert]
      end

      test "should get new" do
        get new_admin_settings_post_status_url

        assert_response :success
      end

      test "should create post status" do
        assert_difference "PostStatus.count", 1 do
          post admin_settings_post_statuses_url, params: {
            post_status: {
              name: "Under Review",
              color: "#ff5733",
              position: 10
            }
          }
        end

        assert_redirected_to admin_settings_post_statuses_path
        assert_equal "Post status was successfully created.", flash[:notice]
      end

      test "renders 422 on invalid create" do
        assert_no_difference "PostStatus.count" do
          post admin_settings_post_statuses_url, params: {
            post_status: {
              name: "",
              color: "",
              position: ""
            }
          }
        end

        assert_response :unprocessable_entity
      end

      test "should get edit" do
        get edit_admin_settings_post_status_url(@post_status)

        assert_response :success
      end

      test "should update post status" do
        patch admin_settings_post_status_url(@post_status), params: {
          post_status: {
            name: "Updated Name",
            color: "#00ff00"
          }
        }

        assert_redirected_to admin_settings_post_statuses_path
        assert_equal "Updated Name", @post_status.reload.name
        assert_equal "#00ff00", @post_status.color
      end

      test "should set status as default when checkbox is checked" do
        new_status = post_statuses(:planned)

        patch admin_settings_post_status_url(new_status), params: {
          post_status: {
            set_as_default: "1"
          }
        }

        assert_equal new_status, @organization.reload.default_post_status
      end

      test "should destroy post status without posts" do
        # Create a new status with no posts
        status_to_delete = PostStatus.create!(
          name: "Temporary",
          color: "#cccccc",
          position: 99
        )

        assert_difference "PostStatus.count", -1 do
          delete admin_settings_post_status_url(status_to_delete)
        end

        assert_redirected_to admin_settings_post_statuses_path
      end

      test "should not destroy default status" do
        default_status = @organization.default_post_status

        # Ensure default status has zero posts to validate the default-protection error specifically
        default_status.posts.destroy_all

        assert_no_difference "PostStatus.count" do
          delete admin_settings_post_status_url(default_status)
        end

        assert_redirected_to admin_settings_post_statuses_path
        assert_equal "Cannot delete the default status. Reassign default to another status first.", flash[:alert]
      end

      test "should not destroy status with posts" do
        # Use in_progress status which has posts but is not default
        status_with_posts = post_statuses(:in_progress)

        assert_predicate status_with_posts.posts, :any?

        assert_no_difference "PostStatus.count" do
          delete admin_settings_post_status_url(status_with_posts)
        end

        assert_redirected_to admin_settings_post_statuses_path
        assert_equal "Cannot delete this status because posts are still using it. Please reassign or delete those posts first.", flash[:alert]
      end
    end
  end
end
