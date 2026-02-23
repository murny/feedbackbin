# frozen_string_literal: true

require "test_helper"

module Admin
  module Settings
    class WebhooksControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:shane)
        @webhook = webhooks(:active)
        sign_in_as @admin
      end

      test "should get index" do
        get admin_settings_webhooks_url

        assert_response :success
      end

      test "should not get index if not an admin" do
        sign_in_as users(:john)

        get admin_settings_webhooks_url

        assert_response :forbidden
      end

      test "should get new" do
        get new_admin_settings_webhook_url

        assert_response :success
      end

      test "should not get new if not an admin" do
        sign_in_as users(:john)

        get new_admin_settings_webhook_url

        assert_response :forbidden
      end

      test "should create webhook" do
        assert_difference "Webhook.count", 1 do
          post admin_settings_webhooks_url, params: {
            webhook: {
              name: "New Webhook",
              url: "https://example.com/new-hook",
              board_id: boards(:one).id,
              subscribed_actions: %w[idea_created]
            }
          }
        end

        assert_redirected_to admin_settings_webhook_path(Webhook.last)
        assert_equal I18n.t("admin.settings.webhooks.create.successfully_created"), flash[:notice]
      end

      test "renders 422 on invalid create" do
        assert_no_difference "Webhook.count" do
          post admin_settings_webhooks_url, params: {
            webhook: {
              name: "",
              url: "not-a-url",
              board_id: boards(:one).id,
              subscribed_actions: []
            }
          }
        end

        assert_response :unprocessable_entity
      end

      test "should not create webhook if not an admin" do
        sign_in_as users(:john)

        assert_no_difference "Webhook.count" do
          post admin_settings_webhooks_url, params: {
            webhook: {
              name: "Unauthorized",
              url: "https://example.com/hook",
              board_id: boards(:one).id,
              subscribed_actions: %w[idea_created]
            }
          }
        end

        assert_response :forbidden
      end

      test "should get show" do
        get admin_settings_webhook_url(@webhook)

        assert_response :success
      end

      test "should get edit" do
        get edit_admin_settings_webhook_url(@webhook)

        assert_response :success
      end

      test "should update webhook name and subscribed actions" do
        patch admin_settings_webhook_url(@webhook), params: {
          webhook: {
            name: "Updated Name",
            subscribed_actions: %w[idea_created comment_created]
          }
        }

        assert_redirected_to admin_settings_webhook_path(@webhook)
        assert_equal "Updated Name", @webhook.reload.name
        assert_equal %w[idea_created comment_created], @webhook.subscribed_actions
      end

      test "update cannot change url" do
        original_url = @webhook.url

        patch admin_settings_webhook_url(@webhook), params: {
          webhook: {
            url: "https://attacker.example.com/hook",
            name: @webhook.name,
            subscribed_actions: @webhook.subscribed_actions
          }
        }

        assert_equal original_url, @webhook.reload.url
      end

      test "renders 422 on invalid update" do
        patch admin_settings_webhook_url(@webhook), params: {
          webhook: { name: "" }
        }

        assert_response :unprocessable_entity
      end

      test "should destroy webhook" do
        assert_difference "Webhook.count", -1 do
          delete admin_settings_webhook_url(@webhook)
        end

        assert_redirected_to admin_settings_webhooks_path
        assert_equal I18n.t("admin.settings.webhooks.destroy.successfully_destroyed"), flash[:notice]
      end

      test "should not destroy webhook if not an admin" do
        sign_in_as users(:john)

        assert_no_difference "Webhook.count" do
          delete admin_settings_webhook_url(@webhook)
        end

        assert_response :forbidden
      end
    end
  end
end
