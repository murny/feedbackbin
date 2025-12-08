# frozen_string_literal: true

module Admin
  module Settings
    class BrandingsController < Admin::BaseController
      def show
        @organization = Current.organization
      end

      def update
        @organization = Current.organization

        if @organization.update(organization_params)
          redirect_to admin_settings_branding_path, notice: t(".successfully_updated")
        else
          # Reload to discard invalid attachments and show the actual persisted state
          @organization.reload
          render :show, status: :unprocessable_entity
        end
      end

      private

        def organization_params
          params.require(:organization).permit(
            :name,
            :subdomain,
            :logo,
            :show_company_name,
            :logo_link,
            :favicon,
            :og_image
          )
        end
    end
  end
end
