# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def index
      users = User.includes(:organizations)
                  .search(params[:search])
                  .order(created_at: :desc)

      @pagy, @users = pagy(users)

      respond_to do |format|
        format.html
        format.turbo_stream { render "index" }
      end
    end

    def show
      @user = User.find(params[:id])
      @recent_posts = @user.posts.includes(:organization).limit(5)
      @memberships = @user.memberships.includes(:organization)
    end
  end
end