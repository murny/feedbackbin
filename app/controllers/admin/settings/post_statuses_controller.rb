# frozen_string_literal: true

module Admin
  module Settings
    class PostStatusesController < Admin::BaseController
      before_action :set_post_status, only: [ :edit, :update, :destroy ]

      def index
        @post_statuses = PostStatus.ordered
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
        # Handle default status assignment (this affects Organization, not PostStatus)
        if params[:post_status][:set_as_default] == "1"
          Current.organization.update!(default_post_status: @post_status)
        end

        if @post_status.update(post_status_params)
          redirect_to admin_settings_post_statuses_path, notice: t(".successfully_updated")
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        # Check if it's the default status
        if @post_status == Current.organization.default_post_status
          redirect_to admin_settings_post_statuses_path, alert: t(".cannot_delete_default")
          return
        end

        # Check if it has posts
        if @post_status.posts.any?
          redirect_to admin_settings_post_statuses_path, alert: t(".cannot_delete_with_posts", count: @post_status.posts.count)
          return
        end

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
          params.require(:post_status).permit(:name, :color, :position)
        end
    end
  end
end
