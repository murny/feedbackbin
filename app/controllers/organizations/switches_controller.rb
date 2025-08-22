# frozen_string_literal: true

module Organizations
  class SwitchesController < ApplicationController
    before_action :set_target_organization

    # POST /organizations/:organization_id/switch
    def create
      authorize @organization, :switch?, policy_class: OrganizationPolicy

      session[:organization_id] = @organization.id
      redirect_back(fallback_location: root_path, notice: t(".successfully_switched", name: @organization.name))
    end

    private

      def set_target_organization
        @organization = Organization.find_by(id: params.expect(:organization_id))
      end
  end
end
