# frozen_string_literal: true

module Admin
  module Settings
    class NavigationsController < Admin::BaseController
      def show
      end

      def update
        if Current.organization.update(organization_params)
          redirect_to admin_settings_navigation_path, notice: t(".successfully_updated")
        else
          render :show, status: :unprocessable_entity
        end
      end

      private

        def organization_params
          params.require(:organization).permit(
            :posts_enabled,
            :roadmap_enabled,
            :changelog_enabled,
            :root_path_module
          )
        end
    end
  end
end
