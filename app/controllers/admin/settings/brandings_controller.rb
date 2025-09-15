# frozen_string_literal: true

module Admin
  module Settings
    class BrandingsController < Admin::BaseController
      def show
      end

      def update
        if Current.organization.update(organization_params)
          redirect_to admin_settings_branding_path, notice: t(".successfully_updated")
        else
          render :show, status: :unprocessable_entity
        end
      end

      private

        def organization_params
          params.require(:organization).permit(:name, :logo, :subdomain).compact
        end
    end
  end
end
