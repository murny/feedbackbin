# frozen_string_literal: true

require "test_helper"

module Admin
  module Settings
    class BrandingsControllerTest < ActionDispatch::IntegrationTest
      setup do
        sign_in_as users(:shane)
      end

      test "should get show" do
        get admin_settings_branding_url

        assert_response :success
      end

      test "should update branding" do
        patch admin_settings_branding_url, params: {
          account: {
            name: "New Name"
          }
        }

        assert_redirected_to admin_settings_branding_url
        follow_redirect!

        assert_response :success
        assert_equal "Branding settings were successfully updated.", flash[:notice]
      end

      test "should upload logo" do
        file = fixture_file_upload("random.jpeg", "image/jpeg")

        patch admin_settings_branding_url, params: { account: { logo: file } }

        assert_redirected_to admin_settings_branding_url
        assert_equal "Branding settings were successfully updated.", flash[:notice]
      end

      test "should not allow non-admin" do
        sign_in_as users(:john)

        patch admin_settings_branding_url, params: { account: { name: "New Name" } }

        assert_response :forbidden
      end

      # Enhanced branding tests
      test "should update show_company_name" do
        patch admin_settings_branding_url, params: {
          account: { show_company_name: false }
        }

        assert_redirected_to admin_settings_branding_url
        assert_not accounts(:feedbackbin).reload.show_company_name
      end

      test "should update logo_link" do
        patch admin_settings_branding_url, params: {
          account: { logo_link: "https://example.com" }
        }

        assert_redirected_to admin_settings_branding_url
        assert_equal "https://example.com", accounts(:feedbackbin).reload.logo_link
      end

      test "should upload favicon" do
        file = fixture_file_upload("random.jpeg", "image/jpeg")

        patch admin_settings_branding_url, params: { account: { favicon: file } }

        assert_redirected_to admin_settings_branding_url
        assert_predicate accounts(:feedbackbin).reload.favicon, :attached?
      end

      test "should upload og_image" do
        file = fixture_file_upload("random.jpeg", "image/jpeg")

        patch admin_settings_branding_url, params: { account: { og_image: file } }

        assert_redirected_to admin_settings_branding_url
        assert_predicate accounts(:feedbackbin).reload.og_image, :attached?
      end

      test "should reject invalid logo_link" do
        patch admin_settings_branding_url, params: {
          account: { logo_link: "javascript:alert('xss')" }
        }

        assert_response :unprocessable_entity
      end
    end
  end
end
