# frozen_string_literal: true

module Admin
  module Settings
    module Webhooks
      class ActivationsController < Admin::BaseController
        def create
          webhook = Current.account.webhooks.find(params[:webhook_id])
          webhook.activate

          redirect_to admin_settings_webhook_path(webhook), notice: t(".successfully_activated")
        end

        def destroy
          webhook = Current.account.webhooks.find(params[:webhook_id])
          webhook.deactivate

          redirect_to admin_settings_webhook_path(webhook), notice: t(".successfully_deactivated")
        end
      end
    end
  end
end
