# frozen_string_literal: true

require "test_helper"

module Admin
  module Settings
    class DangerZonesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @organization = organizations(:feedbackbin)
        sign_in_as users(:shane)
      end

      test "shows danger zone page" do
        get admin_settings_danger_zone_url

        assert_response :success
      end

      test "rejects destroy when confirmation mismatch" do
        assert_no_difference("Organization.count") do
          delete admin_settings_danger_zone_url, params: { organization: { name: "Wrong", acknowledge: "0" } }
        end

        assert_response :unprocessable_entity
        assert_equal "Organization name does not match.", flash[:alert]
      end

      test "rejects destroy when acknowledgment missing" do
        assert_no_difference("Organization.count") do
          delete admin_settings_danger_zone_url, params: { organization: { name: @organization.name, acknowledge: "0" } }
        end

        assert_response :unprocessable_entity
        assert_equal "You must acknowledge this action to proceed.", flash[:alert]
      end

      test "destroys organization with correct confirmation" do
        assert_difference("Organization.count", -1) do
          delete admin_settings_danger_zone_url, params: { organization: { name: @organization.name, acknowledge: "1" } }
        end

        assert_redirected_to root_url
        assert_equal "Organization has been successfully deleted.", flash[:notice]
      end

      test "non-admin cannot access" do
        sign_in_as users(:two)
        get admin_settings_danger_zone_url

        assert_response :redirect
        assert_equal "You are not authorized to perform this action.", flash[:alert]
      end

      test "non-owner admin cannot view danger zone" do
        # Create another admin who is not the owner
        admin = User.create!(
          username: "admin_user",
          name: "Admin User",
          email_address: "admin@feedbackbin.com",
          password: "secret123456",
          role: :administrator
        )
        sign_in_as(admin)

        get admin_settings_danger_zone_url

        assert_redirected_to root_path
        assert_equal "You are not authorized to perform this action.", flash[:alert]
      end

      test "non-owner admin cannot delete organization" do
        # Create another admin who is not the owner
        admin = User.create!(
          username: "admin_user",
          name: "Admin User",
          email_address: "admin@feedbackbin.com",
          password: "secret123456",
          role: :administrator
        )
        sign_in_as(admin)

        assert_no_difference("Organization.count") do
          delete admin_settings_danger_zone_url, params: { organization: { name: @organization.name, acknowledge: "1" } }
        end

        assert_redirected_to root_path
        assert_equal "You are not authorized to perform this action.", flash[:alert]
      end
    end
  end
end
