# frozen_string_literal: true

require "test_helper"

module Admin
  module Settings
    class StatusesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:shane)
        @status = statuses(:planned)
        @account = accounts(:feedbackbin)
        sign_in_as @admin
      end

      test "should get index" do
        get admin_settings_statuses_url

        assert_response :success
      end

      test "should not get index if not an admin" do
        sign_in_as users(:john)

        get admin_settings_statuses_url

        assert_response :forbidden
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
        assert_equal "Status was successfully deleted.", flash[:notice]
      end

      test "should destroy status and nullify ideas using it" do
        # Use in_progress status which has ideas
        status_with_ideas = statuses(:in_progress)
        idea = ideas(:three)

        assert_equal status_with_ideas, idea.status

        assert_difference "Status.count", -1 do
          delete admin_settings_status_url(status_with_ideas)
        end

        assert_redirected_to admin_settings_statuses_path
        assert_equal "Status was successfully deleted.", flash[:notice]

        # Idea should now have nil status (which means "Open")
        idea.reload

        assert_nil idea.status
        assert_predicate idea, :open?
      end
    end
  end
end
