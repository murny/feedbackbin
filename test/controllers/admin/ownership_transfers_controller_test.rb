# frozen_string_literal: true

require "test_helper"

module Admin
  class OwnershipTransfersControllerTest < ActionDispatch::IntegrationTest
    setup do
      @organization = organizations(:feedbackbin)
      @owner = users(:shane)
      @admin = User.create!(
        username: "admin_two",
        name: "Admin Two",
        email_address: "admin2@feedbackbin.com",
        password: "secret123456",
        role: :administrator
      )
      sign_in_as(@owner)
    end

    test "owner can access transfer form" do
      get new_admin_ownership_transfer_url

      assert_response :success
    end

    test "non-owner cannot access transfer form" do
      sign_in_as(@admin)

      get new_admin_ownership_transfer_url

      assert_redirected_to root_path
      assert_equal I18n.t("unauthorized"), flash[:alert]
    end

    test "owner can transfer ownership to another admin" do
      post admin_ownership_transfer_url, params: { new_owner_id: @admin.id }

      assert_redirected_to admin_settings_branding_path
      assert_equal @admin, @organization.reload.owner
      assert_equal "Ownership transferred to Admin Two.", flash[:notice]
    end

    test "cannot transfer to non-administrator" do
      member = users(:one)

      post admin_ownership_transfer_url, params: { new_owner_id: member.id }

      assert_redirected_to new_admin_ownership_transfer_path
      assert_equal @owner, @organization.reload.owner
      assert_equal "The new owner must be an administrator.", flash[:alert]
    end

    test "non-owner cannot transfer ownership" do
      sign_in_as(@admin)

      post admin_ownership_transfer_url, params: { new_owner_id: @owner.id }

      assert_redirected_to root_path
      assert_equal I18n.t("unauthorized"), flash[:alert]
    end
  end
end
