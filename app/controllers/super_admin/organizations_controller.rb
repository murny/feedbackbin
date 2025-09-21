# frozen_string_literal: true

module SuperAdmin
  class OrganizationsController < SuperAdmin::BaseController
    def index
      organizations = Organization.search(params[:search])
                                  .order(created_at: :desc)

      @pagy, @organizations = pagy(organizations)

      respond_to do |format|
        format.html
        format.turbo_stream { render "index" }
      end
    end

    def show
      @organization = Organization.find(params[:id])
    end
  end
end
