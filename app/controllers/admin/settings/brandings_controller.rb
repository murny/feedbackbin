# frozen_string_literal: true

module Admin
  module Settings
    class BrandingsController < Admin::BaseController
      def show
        @account = Current.account
      end

      def update
        @account = Current.account

        if @account.update(account_params)
          redirect_to admin_settings_branding_path, notice: t(".successfully_updated")
        else
          # Reload to discard invalid attachments and show the actual persisted state
          @account.reload
          render :show, status: :unprocessable_entity
        end
      end

      private

        def account_params
          params.require(:account).permit(
            :name,
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
