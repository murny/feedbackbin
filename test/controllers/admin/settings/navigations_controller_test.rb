# frozen_string_literal: true

require "test_helper"

module Admin
  module Settings
    class NavigationsControllerTest < ActionDispatch::IntegrationTest
      setup do
        sign_in_as users(:shane)
        @organization = organizations(:feedbackbin)
      end

      test "should get show" do
        get admin_settings_navigation_url

        assert_response :success
      end

      test "can disable individual modules" do
        patch admin_settings_navigation_url, params: {
          organization: { roadmap_enabled: false }
        }

        assert_redirected_to admin_settings_navigation_url
        assert_not @organization.reload.roadmap_enabled?
      end

      test "cannot disable all modules" do
        patch admin_settings_navigation_url, params: {
          organization: {
            posts_enabled: false,
            roadmap_enabled: false,
            changelog_enabled: false
          }
        }

        assert_response :unprocessable_entity
        assert @organization.reload.posts_enabled?
      end

      test "cannot set disabled module as root path" do
        patch admin_settings_navigation_url, params: {
          organization: {
            roadmap_enabled: false,
            root_path_module: "roadmap"
          }
        }

        assert_response :unprocessable_entity
      end

      test "can update root path module" do
        patch admin_settings_navigation_url, params: {
          organization: { root_path_module: "roadmap" }
        }

        assert_redirected_to admin_settings_navigation_url
        assert_equal "roadmap", @organization.reload.root_path_module
      end

      test "should not allow non-admin" do
        sign_in_as users(:two)

        patch admin_settings_navigation_url, params: { organization: { roadmap_enabled: false } }

        assert_redirected_to root_url
        assert_equal "You are not authorized to perform this action.", flash[:alert]
      end
    end
  end
end
