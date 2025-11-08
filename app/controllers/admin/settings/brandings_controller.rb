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
          params.require(:organization).permit(
            :name,
            :subdomain,
            :logo,
            :logo_display_mode,
            :logo_link,
            :favicon,
            :og_image
          ).compact
        end
    end
  end
end
