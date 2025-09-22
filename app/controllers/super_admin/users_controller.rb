# frozen_string_literal: true

module SuperAdmin
  class UsersController < SuperAdmin::BaseController
    def index
      users = User.with_attached_avatar
                  .search(params[:search])
                  .order(created_at: :desc)

      @pagy, @users = pagy(users)

      respond_to do |format|
        format.html
        format.turbo_stream { render "index" }
      end
    end

    def show
      @user = User.with_attached_avatar.find(params[:id])
      @recent_posts = @user.posts.limit(5)
    end
  end
end
