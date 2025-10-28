# frozen_string_literal: true

module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [ :show, :update_role, :activate, :deactivate ]

    def index
      users = User.with_attached_avatar

      # Apply search filter
      users = users.search(params[:search]) if params[:search].present?

      # Apply role filter
      users = users.where(role: params[:role]) if params[:role].present?

      # Apply status filter
      users = users.where(active: params[:status] == "active") if params[:status].present?

      # Order by name
      users = users.order(name: :asc)

      @pagy, @users = pagy(users)

      respond_to do |format|
        format.html
        format.turbo_stream { render "index" }
      end
    end

    def show
      @recent_posts = @user.posts.order(created_at: :desc).limit(10)

      # Activity stats
      @total_posts = @user.posts.count
      @total_comments = @user.comments.count
      @total_likes = @user.likes.count

      # Last session info
      @last_session = @user.sessions.order(last_active_at: :desc).first
    end

    def update_role
      if @user.update(role: params[:role])
        redirect_to admin_user_path(@user), notice: t(".role_updated_successfully")
      else
        redirect_to admin_user_path(@user), alert: @user.errors.full_messages.to_sentence
      end
    end

    def activate
      if @user.update(active: true)
        redirect_to admin_user_path(@user), notice: t(".activated_successfully")
      else
        redirect_to admin_user_path(@user), alert: @user.errors.full_messages.to_sentence
      end
    end

    def deactivate
      if @user.deactivate
        redirect_to admin_user_path(@user), notice: t(".deactivated_successfully")
      else
        redirect_to admin_user_path(@user), alert: @user.errors.full_messages.to_sentence
      end
    end

    private

      def set_user
        @user = User.with_attached_avatar.find(params[:id])
      end
  end
end
