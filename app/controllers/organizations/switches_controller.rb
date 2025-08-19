# frozen_string_literal: true

module Organizations
  class SwitchesController < ApplicationController
    before_action :set_organization

    # POST /organizations/:organization_id/switch
    def create
      authorize @organization, :switch?

      session[:organization_id] = @organization.id
      redirect_to url_from(params[:return_to]) || root_path, notice: t(".successfully_switched", name: @organization.name)
    end

    private

      def set_organization
        @organization = Current.organizations.find(params.expect(:organization_id))
      rescue ActiveRecord::RecordNotFound
        redirect_back(fallback_location: root_path, alert: t("organizations.switches.unauthorized_switch"))
      end
  end
end
