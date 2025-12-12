# frozen_string_literal: true

require "test_helper"

module Admin
  module Settings
    class StatusesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:shane)
        @status = statuses(:open)
        @account = accounts(:feedbackbin)
        sign_in_as @admin
      end

      test "should get index" do
        get admin_settings_statuses_url

        assert_response :success
      end

      test "should not get index if not an admin" do
        sign_in_as users(:two)

        get admin_settings_statuses_url

        assert_response :redirect
        assert_equal I18n.t("unauthorized"), flash[:alert]
      end

      test "should get new" do
        get new_admin_settings_status_url

        assert_response :success
      end

      test "should create status" do
        assert_difference "Status.count", 1 do
          post admin_settings_statuses_url, params: {
            status: {
              name: "Under Review",
              color: "#ff5733",
              position: 10
            }
          }
        end

        assert_redirected_to admin_settings_statuses_path
        assert_equal "Status was successfully created.", flash[:notice]
      end

      test "renders 422 on invalid create" do
        assert_no_difference "Status.count" do
          post admin_settings_statuses_url, params: {
            status: {
              name: "",
              color: "",
              position: ""
            }
          }
        end

        assert_response :unprocessable_entity
      end

      test "should get edit" do
        get edit_admin_settings_status_url(@status)

        assert_response :success
      end

      test "should update status" do
        patch admin_settings_status_url(@status), params: {
          status: {
            name: "Updated Name",
            color: "#00ff00"
          }
        }

        assert_redirected_to admin_settings_statuses_path
        assert_equal "Updated Name", @status.reload.name
        assert_equal "#00ff00", @status.color
      end

      test "should set status as default when checkbox is checked" do
        new_status = statuses(:planned)

        patch admin_settings_status_url(new_status), params: {
          status: {
            set_as_default: "1"
          }
        }

        assert_equal new_status, @account.reload.default_status
      end

      test "should destroy status without ideas" do
        # Create a new status with no ideas
        status_to_delete = Status.create!(
          name: "Temporary",
          color: "#cccccc",
          position: 99
        )

        assert_difference "Status.count", -1 do
          delete admin_settings_status_url(status_to_delete)
        end

        assert_redirected_to admin_settings_statuses_path
      end

      test "should not destroy default status" do
        default_status = @account.default_status

        # Ensure default status has zero ideas to validate the default-protection error specifically
        default_status.ideas.destroy_all

        assert_no_difference "Status.count" do
          delete admin_settings_status_url(default_status)
        end

        assert_redirected_to admin_settings_statuses_path
        assert_equal "Cannot delete the default status. Reassign default to another status first.", flash[:alert]
      end

      test "should not destroy status with ideas" do
        # Use in_progress status which has ideas but is not default
        status_with_ideas = statuses(:in_progress)

        assert_predicate status_with_ideas.ideas, :any?

        assert_no_difference "Status.count" do
          delete admin_settings_status_url(status_with_ideas)
        end

        assert_redirected_to admin_settings_statuses_path
        assert_equal "Cannot delete this status because ideas are still using it. Please reassign or delete those ideas first.", flash[:alert]
      end
    end
  end
end
