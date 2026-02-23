# frozen_string_literal: true

require "test_helper"

module Admin
  module Settings
    module Webhooks
      class ActivationsControllerTest < ActionDispatch::IntegrationTest
        setup do
          @admin = users(:shane)
          sign_in_as @admin
        end

        test "activating an inactive webhook makes it active" do
          webhook = webhooks(:inactive)
          webhook.deactivate

          post admin_settings_webhook_activation_url(webhook)

          assert_predicate webhook.reload, :active?
          assert_redirected_to admin_settings_webhook_path(webhook)
          assert_equal I18n.t("admin.settings.webhooks.activations.create.successfully_activated"), flash[:notice]
        end

        test "deactivating an active webhook makes it inactive" do
          webhook = webhooks(:active)

          delete admin_settings_webhook_activation_url(webhook)

          assert_not webhook.reload.active?
          assert_redirected_to admin_settings_webhook_path(webhook)
          assert_equal I18n.t("admin.settings.webhooks.activations.destroy.successfully_deactivated"), flash[:notice]
        end

        test "non-admin cannot activate webhook" do
          sign_in_as users(:john)
          webhook = webhooks(:inactive)

          post admin_settings_webhook_activation_url(webhook)

          assert_response :forbidden
          assert_not webhook.reload.active?
        end

        test "non-admin cannot deactivate webhook" do
          sign_in_as users(:john)
          webhook = webhooks(:active)

          delete admin_settings_webhook_activation_url(webhook)

          assert_response :forbidden
          assert_predicate webhook.reload, :active?
        end
      end
    end
  end
end
