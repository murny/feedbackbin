# frozen_string_literal: true

module Admin
  module Settings
    class PostStatusesController < Admin::BaseController
      before_action :set_post_status, only: [ :edit, :update, :destroy ]

      def index
        @post_statuses = PostStatus.includes(:posts).ordered
      end

      def new
        @post_status = PostStatus.new
      end

      def create
        @post_status = PostStatus.new(post_status_params)

        if @post_status.save
          redirect_to admin_settings_post_statuses_path, notice: t(".successfully_created")
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
      end

      def update
        # TODO: updating of default status should get moved to a more specific action
        # Handle default status assignment (this affects Organization, not PostStatus)
        if params.dig(:post_status, :set_as_default) == "1"
          Current.organization.update!(default_post_status: @post_status)
        end

        if @post_status.update(post_status_params)
          redirect_to admin_settings_post_statuses_path, notice: t(".successfully_updated")
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        if @post_status.destroy
          redirect_to admin_settings_post_statuses_path, notice: t(".successfully_destroyed")
        else
          redirect_to admin_settings_post_statuses_path, alert: @post_status.errors.full_messages.to_sentence
        end
      end

      private

        def set_post_status
          @post_status = PostStatus.find(params[:id])
        end

        def post_status_params
          params.require(:post_status).permit(:name, :color, :position, :show_on_feedback, :show_on_roadmap)
        end
    end
  end
end
