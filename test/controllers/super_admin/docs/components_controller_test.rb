# frozen_string_literal: true

require "test_helper"

module SuperAdmin
  module Docs
    class ComponentsControllerTest < ActionDispatch::IntegrationTest
      test "should get alert docs as admin" do
        sign_in_as users(:shane)

        get super_admin_docs_components_alert_path

        assert_response :success
      end

      test "should get avatar docs as admin" do
        sign_in_as users(:shane)

        get super_admin_docs_components_avatar_path

        assert_response :success
      end

      test "should get badge docs as admin" do
        sign_in_as users(:shane)

        get super_admin_docs_components_badge_path

        assert_response :success
      end

      test "should get breadcrumb docs as admin" do
        sign_in_as users(:shane)

        get super_admin_docs_components_breadcrumb_path

        assert_response :success
      end

      test "should get button docs as admin" do
        sign_in_as users(:shane)

        get super_admin_docs_components_button_path

        assert_response :success
      end

      test "should get card docs as admin" do
        sign_in_as users(:shane)

        get super_admin_docs_components_card_path

        assert_response :success
      end

      test "should get tabs docs as admin" do
        sign_in_as users(:shane)

        get super_admin_docs_components_tabs_path

        assert_response :success
      end

      test "should get toast docs as admin" do
        sign_in_as users(:shane)

        get super_admin_docs_components_toast_path

        assert_response :success
      end
    end
  end
end
