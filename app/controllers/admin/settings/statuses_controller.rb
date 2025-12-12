# frozen_string_literal: true

module Admin
  module Settings
    class StatusesController < Admin::BaseController
      before_action :set_status, only: [ :edit, :update, :destroy ]

      def index
        @statuses = Status.includes(:ideas).ordered
      end

      def new
        @status = Status.new
      end

      def create
        @status = Status.new(status_params)

        if @status.save
          redirect_to admin_settings_statuses_path, notice: t(".successfully_created")
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
      end

      def update
        # TODO: updating of default status should get moved to a more specific action
        # Handle default status assignment (this affects Account, not Status)
        if params.dig(:status, :set_as_default) == "1"
          Current.account.update!(default_status: @status)
        end

        if @status.update(status_params)
          redirect_to admin_settings_statuses_path, notice: t(".successfully_updated")
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        if @status.destroy
          redirect_to admin_settings_statuses_path, notice: t(".successfully_destroyed")
        else
          redirect_to admin_settings_statuses_path, alert: @status.errors.full_messages.to_sentence
        end
      end

      private

        def set_status
          @status = Status.find(params[:id])
        end

        def status_params
          params.require(:status).permit(:name, :color, :position, :show_on_idea, :show_on_roadmap)
        end
    end
  end
end
