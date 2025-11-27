# frozen_string_literal: true

module Admin
  module Settings
    class ThemesController < Admin::BaseController
      def show
      end

      def update
        if Current.organization.update(organization_params)
          redirect_to admin_settings_theme_path, notice: t(".successfully_updated")
        else
          render :show, status: :unprocessable_entity
        end
      end

      private

        def organization_params
          params.require(:organization).permit(
            :theme,
            :accent_color,
            :allow_user_theme_choice
          )
        end
    end
  end
end
