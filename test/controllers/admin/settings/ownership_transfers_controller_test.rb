# frozen_string_literal: true

require "test_helper"

module Admin
  module Settings
    class OwnershipTransfersControllerTest < ActionDispatch::IntegrationTest
      setup do
        @organization = organizations(:feedbackbin)
        @owner = users(:shane)
        @admin = User.create!(
          name: "Admin Two",
          email_address: "admin2@feedbackbin.com",
          password: "secret123456",
          role: :administrator
        )
        sign_in_as(@owner)
      end

      test "owner can access transfer form" do
        get new_admin_settings_ownership_transfer_url

        assert_response :success
      end

      test "non-owner cannot access transfer form" do
        sign_in_as(@admin)

        get new_admin_settings_ownership_transfer_url

        assert_redirected_to root_path
        assert_equal I18n.t("unauthorized"), flash[:alert]
      end

      test "owner can transfer ownership to another admin" do
        post admin_settings_ownership_transfer_url, params: { new_owner_id: @admin.id }

        assert_redirected_to admin_settings_branding_path
        assert_equal @admin, @organization.reload.owner
        assert_equal "Ownership transferred to Admin Two.", flash[:notice]
      end

      test "non-owner cannot transfer ownership" do
        sign_in_as(@admin)

        post admin_settings_ownership_transfer_url, params: { new_owner_id: @owner.id }

        assert_redirected_to root_path
        assert_equal I18n.t("unauthorized"), flash[:alert]
      end
    end
  end
end
