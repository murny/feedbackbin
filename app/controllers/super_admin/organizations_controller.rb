# frozen_string_literal: true

module SuperAdmin
  class OrganizationsController < SuperAdmin::BaseController
    def index
      organizations = Organization
                                  .search(params[:search])
                                  .order(created_at: :desc)

      @pagy, @organizations = pagy(organizations)

      respond_to do |format|
        format.html
        format.turbo_stream { render "index" }
      end
    end

    def show
      @organization = Organization.find(params[:id])
      @recent_posts = Post.includes(:author).limit(5)
      @users = User.limit(5)
    end
  end
end
