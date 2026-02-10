# frozen_string_literal: true

module Admin
  module Settings
    class WebhooksController < Admin::BaseController
      before_action :set_webhook, only: [ :show, :edit, :update, :destroy ]

      def index
        @webhooks = Current.account.webhooks.includes(:board).order(created_at: :desc)
      end

      def show
      end

      def new
        @webhook = Webhook.new
        @boards = Current.account.boards.ordered
      end

      def create
        @webhook = Current.account.webhooks.build(webhook_params)

        if @webhook.save
          redirect_to admin_settings_webhook_path(@webhook), notice: t(".successfully_created")
        else
          @boards = Current.account.boards.ordered
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @boards = Current.account.boards.ordered
      end

      def update
        # URL cannot be changed after creation (security best practice)
        if @webhook.update(webhook_params.except(:url))
          redirect_to admin_settings_webhook_path(@webhook), notice: t(".successfully_updated")
        else
          @boards = Current.account.boards.ordered
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
