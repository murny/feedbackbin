# frozen_string_literal: true

module Admin
  class OrganizationsController < BaseController
    def index
      organizations = Organization.includes(:owner, :users)
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
      @recent_posts = @organization.posts.includes(:author).limit(5)
      @recent_memberships = @organization.memberships.includes(:user).limit(5)
    end
  end
end
