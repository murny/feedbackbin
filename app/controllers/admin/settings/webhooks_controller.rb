# frozen_string_literal: true

module Admin
  module Settings
    class WebhooksController < Admin::BaseController
      before_action :set_webhook, only: [ :edit, :update, :destroy, :activate, :deactivate ]

      def index
        @webhooks = Current.account.webhooks.includes(:board).order(created_at: :desc)
      end

      def new
        @webhook = Webhook.new
        @boards = Board.ordered
      end

      def create
        @webhook = Webhook.new(webhook_params)

        if @webhook.save
          redirect_to admin_settings_webhooks_path, notice: t(".successfully_created")
        else
          @boards = Board.ordered
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @boards = Board.ordered
      end

      def update
        if @webhook.update(webhook_params)
          redirect_to admin_settings_webhooks_path, notice: t(".successfully_updated")
        else
          @boards = Board.ordered
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        if @webhook.destroy
          redirect_to admin_settings_webhooks_path, notice: t(".successfully_destroyed")
        else
          redirect_to admin_settings_webhooks_path, alert: @webhook.errors.full_messages.to_sentence
        end
      end

      def activate
        @webhook.activate
        redirect_to admin_settings_webhooks_path, notice: t(".successfully_activated")
      end

      def deactivate
        @webhook.deactivate
        redirect_to admin_settings_webhooks_path, notice: t(".successfully_deactivated")
      end

      private

      def set_webhook
        @webhook = Current.account.webhooks.find(params[:id])
      end

      def webhook_params
        params.require(:webhook).permit(:name, :url, :board_id, :description, subscribed_actions: [])
      end
    end
  end
end
