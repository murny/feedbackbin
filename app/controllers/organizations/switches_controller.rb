# frozen_string_literal: true

module Organizations
  class SwitchesController < ApplicationController
    before_action :set_target_organization

    # POST /organizations/:organization_id/switch
    def create
      authorize @organization, :switch?, policy_class: OrganizationPolicy

      # Test that we can use flash messages here?
      redirect_to root_url(subdomain: @organization.subdomain), allow_other_host: true, notice: t(".successfully_switched", name: @organization.name)
    end

    private

      def set_target_organization
        @organization = Organization.find_by(id: params.expect(:organization_id))
      end
  end
end
